defmodule CodeCorpsWeb.ConversationPartController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{
    ConversationPart,
    Messages,
    User
  }

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
         conversation_parts <- ConversationPart |> Policy.scope(current_user) |> Messages.list_parts(params) do
      conn |> render("index.json-api", data: conversation_parts)
    end
  end

  @spec create(Plug.Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %ConversationPart{}, params),
         {:ok, %ConversationPart{} = message} <- Messages.add_part(params),
         message <- preload(message)
    do
      conn |> put_status(:created) |> render("show.json-api", data: message)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
      %ConversationPart{} = conversation_part <- Messages.get_part(id),
      {:ok, :authorized} <- current_user |> Policy.authorize(:show, conversation_part, %{}) do
      conn |> render("show.json-api", data: conversation_part)
    end
  end

  @preloads [:author, :conversation]

  def preload(data) do
    Repo.preload(data, @preloads)
  end
end
