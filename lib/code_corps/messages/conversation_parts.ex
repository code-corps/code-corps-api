defmodule CodeCorps.Messages.ConversationParts do
  @moduledoc ~S"""
  An individual part of a conversation in a `CodeCorps.Conversation` thread,
  i.e. a reply to the `CodeCorps.Conversation` by any participant.
  """

  import Ecto.Changeset, only: [
    assoc_constraint: 2,
    cast: 3,
    validate_required: 2,
    validate_inclusion: 3
  ]

  alias CodeCorps.{
    Conversation,
    ConversationPart,
    Messages,
    Repo
  }
  alias CodeCorpsWeb.ConversationChannel
  alias Ecto.{
    Changeset,
    Multi
  }

  @spec create(map) :: {:ok, ConversationPart.t} | {:error, Changeset.t}
  def create(%{"conversation_id" => id} = attrs) do
    with %Conversation{} = conversation <- Repo.get(Conversation, id),
         {:ok, %ConversationPart{} = conversation_part} <- do_create(attrs, conversation) do
      ConversationChannel.broadcast_new_conversation_part(conversation_part)
      {:ok, conversation_part}
    end
  end

  @spec do_create(map, Conversation.t) :: {:ok, Conversation.t} | {:error, Changeset.t}
  defp do_create(attrs, conversation) do
    Multi.new
    |> Multi.insert(:conversation_part, create_changeset(%ConversationPart{}, attrs))
    |> Multi.update(:conversation, Messages.Conversations.part_added_changeset(conversation))
    |> Repo.transaction()
    |> marshall_result()
  end

  @spec marshall_result(tuple) :: {:ok, ConversationPart.t} | {:error, Changeset.t}
  defp marshall_result({:ok, %{conversation_part: %ConversationPart{} = conversation_part}}), do: {:ok, conversation_part}
  defp marshall_result({:error, :conversation_part, %Changeset{} = changeset, _steps}), do: {:error, changeset}
  defp marshall_result({:error, :conversation, %Changeset{} = changeset, _steps}), do: {:error, changeset}

  @doc false
  @spec create_changeset(ConversationPart.t, map) :: Ecto.Changeset.t
  def create_changeset(%ConversationPart{} = conversation_part, attrs) do
    conversation_part
    |> cast(attrs, [:author_id, :body, :conversation_id, :part_type])
    |> validate_required([:author_id, :body, :conversation_id])
    |> validate_inclusion(:part_type, part_types())
    |> assoc_constraint(:author)
    |> assoc_constraint(:conversation)
  end

  defp part_types do
    ~w{ closed comment note reopened }
  end
end
