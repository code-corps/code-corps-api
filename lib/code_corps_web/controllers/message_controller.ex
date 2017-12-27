defmodule CodeCorpsWeb.MessageController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{
    Message,
    Messages,
    User
  }

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes, [includes_many: ~w(conversation)]
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
         messages <- Message |> Policy.scope(current_user) |> Messages.list(params) |> preload() do
      conn |> render("index.json-api", data: messages)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
      %Message{} = message <- Message |> Repo.get(id) |> preload(),
      {:ok, :authorized} <- current_user |> Policy.authorize(:show, message, %{}) do
      conn |> render("show.json-api", data: message)
    end
  end

  @spec create(Plug.Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %Message{}, params),
         {:ok, %Message{} = message} <- Messages.create(params),
         message <- preload(message)
    do
      conn |> put_status(:created) |> render("show.json-api", data: message)
    end
  end

  @preloads [:author, :project, :conversations]

  def preload(data) do
    Repo.preload(data, @preloads)
  end
end
