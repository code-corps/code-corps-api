defmodule CodeCorps.Messages do
  @moduledoc ~S"""
  Main context for work with the Messaging feature.
  """

  alias CodeCorps.{
    Conversation,
    ConversationPart,
    Helpers.Query,
    Message,
    Messages,
    Repo
  }
  alias Ecto.{Changeset, Queryable}

  @doc ~S"""
  Lists pre-scoped `CodeCorps.Message` records filtered by parameters.
  """
  @spec list(Queryable.t, map) :: list(Message.t)
  def list(scope, %{} = params) do
    scope
    |> Query.id_filter(params)
    |> Repo.all()
  end

  @doc ~S"""
  Lists pre-scoped `CodeCorps.Conversation` records filtered by parameters
  """
  @spec list_conversations(Queryable.t, map) :: list(Conversation.t)
  def list_conversations(scope, %{} = params) do
    scope
    |> Messages.ConversationQuery.project_filter(params)
    |> Messages.ConversationQuery.active_filter(params)
    |> Messages.ConversationQuery.status_filter(params)
    |> Messages.ConversationQuery.user_filter(params)
    |> Repo.all()
  end

  @doc ~S"""
  Lists pre-scoped `CodeCorps.ConversationPart` records filtered by parameters
  """
  @spec list_parts(Queryable.t, map) :: list(Conversation.t)
  def list_parts(scope, %{} = _params) do
    scope |> Repo.all()
  end

  @doc ~S"""
  Gets a `CodeCorps.Conversation` record
  """
  @spec get_conversation(integer) :: Conversation.t
  def get_conversation(id) do
    Conversation |> Repo.get(id)
  end

  def update_conversation(conversation, params) do
    conversation |> Conversation.update_changeset(params) |> Repo.update
  end

  @doc ~S"""
  Gets a `CodeCorps.ConversationPart` record
  """
  @spec get_part(integer) :: ConversationPart.t
  def get_part(id) do
    ConversationPart |> Repo.get(id)
  end

  @doc ~S"""
  Creates a `CodeCorps.Message` from a set of parameters.
  """
  @spec create(map) :: {:ok, Message.t} | {:error, Changeset.t}
  def create(%{} = params) do
    with {:ok, %Message{} = message} <- %Message{} |> create_changeset(params) |> Repo.insert() do
      message |> Messages.Emails.notify_message_targets()
      {:ok, message}
    else
      {:error, %Changeset{} = changeset} -> {:error, changeset}
    end
  end

  @spec create_changeset(Message.t, map) :: Changeset.t
  defp create_changeset(%Message{} = message, %{} = params) do
    message
    |> Message.changeset(params)
    |> Changeset.cast(params, [:author_id, :project_id])
    |> Changeset.validate_required([:author_id, :project_id])
    |> Changeset.assoc_constraint(:author)
    |> Changeset.assoc_constraint(:project)
    |> Changeset.cast_assoc(:conversations, with: &Messages.Conversations.create_changeset/2)
  end

  @spec add_part(map) :: {:ok, ConversationPart.t} | {:error, Changeset.t}
  def add_part(%{} = params) do
    with {:ok, %ConversationPart{} = conversation_part} <- params |> Messages.ConversationParts.create do
      conversation_part |> Messages.Emails.notify_of_new_reply()
      {:ok, conversation_part}
    else
      {:error, %Changeset{} = changeset} -> {:error, changeset}
    end
  end
end
