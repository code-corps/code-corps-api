defmodule CodeCorps.Messages.ConversationQuery do
  @moduledoc ~S"""
  Holds helpers to query `CodeCorps.Conversation` records using a map of params.
  """

  import Ecto.Query

  alias CodeCorps.{Conversation, ConversationPart, Message, Repo}
  alias Ecto.Queryable

  @doc ~S"""
  Narrows down a `CodeCorps.Conversation` query by `project_id` of the parent
  `CodeCorps.Message`, if specified in a params map
  """
  @spec project_filter(Queryable.t, map) :: Queryable.t
  def project_filter(queryable, %{"project_id" => project_id}) do
    queryable
    |> join(:left, [c], m in Message, c.message_id == m.id)
    |> where([_c, m], m.project_id == ^project_id)
  end
  def project_filter(queryable, %{}), do: queryable

  @doc ~S"""
  Narrows down a `CodeCorps.Conversation` query by `user_id`, if specified in a
  params map
  """
  @spec user_filter(Queryable.t, map) :: Queryable.t
  def user_filter(queryable, %{"user_id" => user_id}) do
    queryable
    |> where([c], c.user_id == ^user_id)
  end
  def user_filter(queryable, %{}), do: queryable


  @doc ~S"""
  Narrows down a `CodeCorps.Conversation` query to return only those records
  considered to have a specific status.

  The status of `active` means that only those records are included which either
  - belong to a `CodeCorps.Message` initiated by user
  - belong to a `CodeCorps.Message` initiated by admin, with at least a single
    reply in the form of a `CodeCorps.ConversationPart`
  """
  @spec status_filter(Queryable.t, map) :: Queryable.t
  def status_filter(queryable, %{"status" => "active"}) do
    prefiltered_ids = queryable |> select([c], c.id) |> Repo.all

    Conversation
    |> where([c], c.id in ^prefiltered_ids)
    |> join(:left, [c], m in Message, c.message_id == m.id)
    |> join(:left, [c, _m], cp in ConversationPart, c.id == cp.conversation_id)
    |> group_by([c, m, _cp], [c.id, m.initiated_by])
    |> having([_c, m, _cp], m.initiated_by == "user")
    |> or_having([c, m, cp], m.initiated_by == "admin" and count(cp.id) > 0)
  end
  def status_filter(query, %{}), do: query
end
