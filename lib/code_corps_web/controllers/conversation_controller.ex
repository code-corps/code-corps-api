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
         conversations <- Conversation |> Policy.scope(current_user) |> Messages.list_conversations(params) do
      conn |> render("index.json-api", data: conversations)
    end
  end
end
