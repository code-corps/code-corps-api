defmodule CodeCorps.Policy.Conversation do
  @moduledoc ~S"""
  Handles `CodeCorps.User` authorization of actions on `CodeCorps.Conversation`
  records.
  """

  import CodeCorps.Policy.Helpers,
    only: [administered_by?: 2, get_message: 1, get_project: 1]
  import Ecto.Query

  alias CodeCorps.{Conversation, Message, Policy, Repo, User}

  @spec scope(Ecto.Queryable.t, User.t) :: Ecto.Queryable.t
  def scope(queryable, %User{admin: true}), do: queryable
  def scope(queryable, %User{id: id} = current_user) do
    scoped_message_ids =
      Message
      |> Policy.Message.scope(current_user)
      |> select([m], m.id)
      |> Repo.all

    queryable
    |> where(user_id: ^id)
    |> or_where([c], c.message_id in ^scoped_message_ids)
  end

  def show?(%User{id: user_id}, %Conversation{user_id: target_user_id})
    when user_id == target_user_id do
    true
  end
  def show?(%User{} = user, %Conversation{} = conversation) do
    conversation |> get_message() |> get_project() |> administered_by?(user)
  end
  def show?(_, _), do: false
end
