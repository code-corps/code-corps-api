defmodule CodeCorps.Messages do
  @moduledoc ~S"""
  Main context for work with the Messaging feature.
  """

  alias CodeCorps.{Conversation, Helpers.Query, Message, Messages, Repo}
  alias Ecto.{Changeset, Queryable}

  @doc ~S"""
  Lists pre-scoped `CodeCorps.Message` records filtered by parameters.
  """
  @spec list(Queryable.t, map) :: list(Message.t)
  def list(scope, %{} = params) do
    scope
    |> Query.id_filter(params)
    |> Messages.Query.author_filter(params)
    |> Messages.Query.project_filter(params)
    |> Repo.all()
  end

  @doc ~S"""
  Lists pre-scoped `CodeCorps.Conversation` records filtered by parameters
  """
  @spec list_conversations(Queryable.t, map) :: list(Conversation.t)
  def list_conversations(scope, %{} = params) do
    scope
    |> Messages.ConversationQuery.project_filter(params)
    |> Messages.ConversationQuery.status_filter(params)
    |> Repo.all()
  end

  @doc ~S"""
  Creates a `CodeCorps.Message` from a set of parameters.
  """
  @spec create(map) :: {:ok, Message.t} | {:error, Changeset.t}
  def create(%{} = params) do
    %Message{}
    |> Message.changeset(params)
    |> Repo.insert()
  end
end
