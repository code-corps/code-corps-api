defmodule CodeCorps.Policy.Conversation do
  @moduledoc ~S"""
  Handles `CodeCorps.User` authorization of actions on `CodeCorps.Conversation`
  records.
  """

  import Ecto.Query

  alias CodeCorps.{Message, Policy, Repo, User}

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
end
