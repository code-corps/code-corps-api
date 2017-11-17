defmodule CodeCorpsWeb.GithubEventController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{
    GithubEvent,
    GitHub.Webhook.Handler,
    GitHub.Webhook.EventSupport,
    Helpers.Query,
    Processor,
    Repo,
    User
  }

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:index, %GithubEvent{}, params)
    do
      github_events =
        GithubEvent
        |> Query.id_filter(params)
        |> Ecto.Query.order_by([desc: :inserted_at])
        |> paginate(params)

      conn |> render("index.json-api", data: github_events)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id} = params) do
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         %GithubEvent{} = github_event <- GithubEvent |> Repo.get(id),
         {:ok, :authorized} <- current_user |> Policy.authorize(:show, github_event, params)
    do
      conn |> render("show.json-api", data: github_event)
    end
  end

  @spec create(Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = payload) do
    type = conn |> get_event_type
    delivery_id = conn |> get_delivery_id()
    action = payload |> Map.get("action", "")
    event_support = type |> EventSupport.status(action)
    event_support |> process_event(type, delivery_id, payload)
    conn |> respond_to_webhook(event_support)
  end

  @spec update(Conn.t, map) :: Conn.t
  def update(%Conn{} = conn, %{"id" => id} = params) do
    with %GithubEvent{} = github_event <- GithubEvent |> Repo.get(id),
      %User{} = current_user <- conn |> Guardian.Plug.current_resource,
      {:ok, :authorized} <- current_user |> Policy.authorize(:update, github_event, params),
      changeset <- github_event |> GithubEvent.update_changeset(params),
      {:ok, updated_github_event} <- changeset |> retry_event()
    do
      conn |> render("show.json-api", data: updated_github_event)
    end
  end

  @spec get_event_type(Conn.t) :: String.t
  defp get_event_type(%Conn{} = conn) do
    conn |> get_req_header("x-github-event") |> List.first
  end

  @spec get_delivery_id(Conn.t) :: String.t
  defp get_delivery_id(%Conn{} = conn) do
    conn |> get_req_header("x-github-delivery") |> List.first
  end

  @spec paginate(Ecto.Queryable.t, map) :: list(GithubEvent.t)
  defp paginate(query, %{"page" => page_params}) do
    query |> Repo.paginate(page_params)
  end
  defp paginate(query, _) do
    query |> Repo.all()
  end

  @spec process_event(atom, String.t, String.t, map) :: any | :ok
  defp process_event(:supported, type, delivery_id, payload) do
    Processor.process(fn -> Handler.handle_supported(type, delivery_id, payload) end)
  end
  defp process_event(:unsupported, type, delivery_id, payload) do
    Processor.process(fn -> Handler.handle_unsupported(type, delivery_id, payload) end)
  end
  defp process_event(:ignored, _, _, _), do: :ok

  @type retry_outcome :: {:ok, GithubEvent.t} | {:error, Ecto.Changeset.t} | :ok

  @spec retry_event(Ecto.Changeset.t) :: retry_outcome
  defp retry_event(%Ecto.Changeset{data: %GithubEvent{action: action, type: type}} = changeset) do
    type
    |> EventSupport.status(action)
    |> do_retry_event(changeset)
  end

  @spec do_retry_event(atom, Ecto.Changeset.t) :: retry_outcome
  defp do_retry_event(:ignored, _changeset), do: nil
  defp do_retry_event(support, %Ecto.Changeset{data: %GithubEvent{github_delivery_id: delivery_id, payload: payload, type: type}} = changeset) do
    case changeset |> Repo.update() do
      {:ok, %GithubEvent{} = github_event} ->
        process_event(support, type, delivery_id, payload)
        {:ok, github_event}
      {:error, error} ->
        {:error, error}
    end
  end

  @spec respond_to_webhook(Conn.t, atom) :: Conn.t
  defp respond_to_webhook(conn, :supported), do: conn |> send_resp(200, "")
  defp respond_to_webhook(conn, :unsupported), do: conn |> send_resp(200, "")
  defp respond_to_webhook(conn, :ignored), do: conn |> send_resp(202, "")
end
