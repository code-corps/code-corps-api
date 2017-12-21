defmodule CodeCorps.Messages.ConversationParts do
  @moduledoc ~S"""
  An individual part of a conversation in a `CodeCorps.Conversation` thread,
  i.e. a reply to the `CodeCorps.Conversation` by any participant.
  """

  import Ecto.Changeset, only: [assoc_constraint: 2, cast: 3, validate_required: 2]

  alias CodeCorps.{
    ConversationPart,
    Repo
  }
  alias CodeCorpsWeb.ConversationChannel

  @spec create(map) :: ConversationPart.t | Ecto.Changeset.t
  def create(attrs) do
    with {:ok, %ConversationPart{} = conversation_part} <- %ConversationPart{} |> create_changeset(attrs) |> Repo.insert() do
      ConversationChannel.broadcast_new_conversation_part(conversation_part)
      {:ok, conversation_part}
    end
  end

  @doc false
  @spec create_changeset(ConversationPart.t, map) :: Ecto.Changeset.t
  def create_changeset(%ConversationPart{} = conversation_part, attrs) do
    conversation_part
    |> cast(attrs, [:author_id, :body, :conversation_id])
    |> validate_required([:author_id, :body, :conversation_id])
    |> assoc_constraint(:author)
    |> assoc_constraint(:conversation)
  end
end
