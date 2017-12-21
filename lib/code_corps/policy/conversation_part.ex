defmodule CodeCorps.Policy.ConversationPart do
  @moduledoc ~S"""
  Handles `CodeCorps.User` authorization of actions on `CodeCorps.Conversation`
  records.
  """

  import CodeCorps.Policy.Helpers,
    only: [
      administered_by?: 2, get_conversation: 1, get_message: 1, get_project: 1
    ]
  import Ecto.Query

  alias CodeCorps.{Conversation, ConversationPart, Policy, Repo, User}

  @spec scope(Ecto.Queryable.t, User.t) :: Ecto.Queryable.t
  def scope(queryable, %User{admin: true}), do: queryable
  def scope(queryable, %User{id: id} = current_user) do
    scoped_conversation_ids =
      Conversation
      |> Policy.Conversation.scope(current_user)
      |> select([c], c.id)
      |> Repo.all()

    queryable
    |> where(author_id: ^id)
    |> or_where([cp], cp.conversation_id in ^scoped_conversation_ids)
  end

  def create?(%User{} = user, %{"conversation_id" => _} = params) do
    authorize(user, params)
  end
  def create?(_, _), do: false

  def show?(%User{} = user, %ConversationPart{conversation_id: _} = part) do
    authorize(user, part)
  end
  def show?(_, _), do: false

  @spec authorize(User.t, ConversationPart.t | map) :: boolean
  defp authorize(%User{} = user, attrs) do
    %Conversation{} = conversation = attrs |> get_conversation()
    is_target? = conversation |> conversation_target?(user)

    is_admin? =
      conversation
      |> get_message()
      |> get_project()
      |> administered_by?(user)

    is_target? or is_admin?
  end

  defp conversation_target?(%Conversation{user_id: target_id}, %User{id: user_id}) do
    target_id == user_id
  end
end
