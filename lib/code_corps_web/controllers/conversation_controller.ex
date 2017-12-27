defmodule CodeCorpsWeb.ConversationController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{
    Conversation,
    Messages,
    User
  }

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
         conversations <- Conversation |> Policy.scope(current_user) |> Messages.list_conversations(params) |> preload() do
      conn |> render("index.json-api", data: conversations)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
      %Conversation{} = conversation <- Messages.get_conversation(id) |> preload(),
      {:ok, :authorized} <- current_user |> Policy.authorize(:show, conversation, %{}) do
      conn |> render("show.json-api", data: conversation)
    end
  end

  @spec update(Conn.t, map) :: Conn.t
  def update(%Conn{} = conn, %{"id" => id} = params) do
    with %Conversation{} = conversation <- Messages.get_conversation(id) |> preload(),
         %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:update, conversation),
         {:ok, %Conversation{} = updated_conversation} <- conversation |> Messages.update_conversation(params)
      do

      conn |> render("show.json-api", data: updated_conversation)
    end
  end

  @preloads [:conversation_parts, :message, :user]

  def preload(data) do
    Repo.preload(data, @preloads)
  end
end
