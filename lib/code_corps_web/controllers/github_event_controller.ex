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

    case type |> EventSupport.status(action) do
      :supported ->
        Processor.process(fn -> Handler.handle_supported(type, delivery_id, payload) end)
        conn |> send_resp(200, "")
      :unsupported ->
        Processor.process(fn -> Handler.handle_unsupported(type, delivery_id, payload) end)
        conn |> send_resp(200, "")
      :ignored ->
        conn |> send_resp(202, "")
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
end
