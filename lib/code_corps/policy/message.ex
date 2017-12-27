defmodule CodeCorps.Policy.Message do
  @moduledoc """
  Handles `User` authorization of actions on `Message` records
  """

  import CodeCorps.Policy.Helpers, only: [administered_by?: 2, get_project: 1]
  import Ecto.Query

  alias CodeCorps.{Conversation, Message, Project, ProjectUser, Repo, User}

  @spec scope(Ecto.Queryable.t, User.t) :: Ecto.Queryable.t
  def scope(queryable, %User{admin: true}), do: queryable
  def scope(queryable, %User{id: id}) do
    projects_administered_by_user_ids =
      Project
      |> join(:inner, [p], pu in ProjectUser, pu.project_id == p.id)
      |> where([_p, pu], pu.user_id == ^id)
      |> where([_p, pu], pu.role in ~w(admin owner))
      |> select([p], p.id)
      |> Repo.all

    messages_targeted_at_user_ids =
      Message
      |> join(:inner, [m], c in Conversation, c.message_id == m.id)
      |> where([_m, c], c.user_id == ^id)
      |> select([m, _c], m.id)
      |> Repo.all

    queryable
    |> where([m], m.author_id == ^id)
    |> or_where([m], m.id in ^messages_targeted_at_user_ids)
    |> or_where([m], m.project_id in ^projects_administered_by_user_ids)
  end

  def show?(
    %User{id: user_id},
    %Message{initiated_by: "user", author_id: author_id})
    when user_id == author_id do

    true
  end
  def show?(%User{} = user, %Message{} = message) do
    cond do
      message |> get_project() |> administered_by?(user) -> true
      message.conversations |> Enum.any?(fn c -> c.user_id == user.id end) -> true
      true -> false
    end
  end
  def show?(_, _), do: false

  def create?(%User{id: id}, %{"initiated_by" => "user", "author_id" => author_id}) when id === author_id do
    true
  end
  def create?(%User{} = user, %{"initiated_by" => "admin", "project_id" => _} = params) do
    params |> get_project() |> administered_by?(user)
  end
  def create?(_, _), do: false
end
