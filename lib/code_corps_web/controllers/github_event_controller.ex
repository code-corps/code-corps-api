defmodule CodeCorpsWeb.GithubEventController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{GithubEvent, Helpers.Query, Repo, User}
  alias CodeCorps.GitHub.Webhook.{
    EventSupport, Processor
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
        |> Ecto.Query.order_by([asc: :inserted_at])
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

  def create(conn, event_payload) do
    event_type = conn |> get_event_type()

    case event_type |> EventSupport.status do
      :supported ->
        Processor.process_async(event_type, conn |> get_delivery_id, event_payload)
        conn |> send_resp(200, "")
      :unsupported ->
        conn |> send_resp(202, "")
    end
  end

  defp get_event_type(conn) do
    conn |> get_req_header("x-github-event") |> List.first
  end

  defp get_delivery_id(conn) do
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
