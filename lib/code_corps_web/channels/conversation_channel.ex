defmodule CodeCorpsWeb.ConversationChannel do
  use Phoenix.Channel

  alias CodeCorps.{Conversation, Policy, Repo, User}
  alias Phoenix.Socket

  @spec join(String.t, map, Socket.t) :: {:ok, Socket.t} | {:error, map}
  def join("conversation:" <> id, %{}, %Socket{} = socket) do
    with %Conversation{} = conversation <- Conversation |> Repo.get(id),
         %User{} = current_user <- socket.assigns[:current_user],
         {:ok, :authorized} <- current_user |> Policy.authorize(:show, conversation, %{}) do

        {:ok, socket}
    else
      nil -> {:error, %{reason: "unauthenticated"}}
      {:error, :not_authorized} -> {:error, %{reason: "unauthorized"}}
    end
  end

  def event("new:conversation-part", socket, message) do
    broadcast socket, "new:conversation-part", message
    {:ok, socket}
  end

  def broadcast_new_conversation_part(conversation_part) do
    channel = "conversation:#{conversation_part.conversation_id}"
    event = "new:conversation-part"
    payload = %{
      author_id: conversation_part.author_id,
      id: conversation_part.id
    }

    CodeCorpsWeb.Endpoint.broadcast(channel, event, payload)
  end
end
