defmodule CodeCorps.TaskPolicy do
  import CodeCorps.Helpers.Policy,
    only: [get_project: 1, get_membership: 2, get_role: 1, admin_or_higher?: 1, contributor_or_higher?: 1]

  alias CodeCorps.Task
  alias CodeCorps.User
  alias Ecto.Changeset

  # TODO: Need to be able to see what resource is being created here
  # Previously, any user could create issues and ideas, but only
  # approved members of organization could create other task types
  def create?(%User{admin: true}, %Changeset{}), do: true
  def create?(%User{} = user, %Changeset{changes: %{user_id: author_id, task_type: task_type}} = changeset) do
    cond do
      # can't create for some other user
      user.id != author_id -> false
      # any registered user can create ideas or issues
      task_type in ["idea", "issue"] -> true
      # organization admin or higher can update other people's tasks
      changeset |> get_project |> get_membership(user) |> get_role |> contributor_or_higher? -> true
      # do not permit for any other case
      true -> false
    end
  end
  def create?(%User{}, %Changeset{}), do: false

  def update?(%User{} = user, %Task{user_id: author_id} = task) do
    cond do
      # author can update own task
      user.id == author_id -> true
      # organization admin or higher can update other people's tasks
      task |> get_project |> get_membership(user) |> get_role |> admin_or_higher? -> true
      # do not permit for any other case
      true -> false
    end
  end
end
