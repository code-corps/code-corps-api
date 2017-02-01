defmodule CodeCorps.UserTaskPolicy do
  @moduledoc """
  Represents an authorization policy for performing actions on UserTask records.
  Used to authorize a controller action.
  """
  import CodeCorps.Helpers.Policy,
    only: [get_project: 1, get_membership: 2, get_role: 1, contributor_or_higher?: 1]

  alias CodeCorps.{Repo, Task, UserTask, User}
  alias Ecto.Changeset

  @spec create?(User.t, Changeset.t) :: boolean
  def create?(%User{} = user, %Changeset{} = changeset) do
    cond do
      changeset |> get_task |> get_project |> get_membership(user) |> get_role |> contributor_or_higher? -> true
      changeset |> get_task |> authored_by?(user) -> true
      true -> false
    end
  end

  @spec delete?(User.t, UserTask.t) :: boolean
  def delete?(%User{} = user, %UserTask{} = user_task) do
    cond do
      user_task |> get_task |> get_project |> get_membership(user) |> get_role |> contributor_or_higher? -> true
      user_task |> get_task |> authored_by?(user) -> true
      true -> false
    end
  end

  defp get_task(%UserTask{task_id: task_id}), do: Repo.get(Task, task_id)
  defp get_task(%Changeset{changes: %{task_id: task_id}}), do: Repo.get(Task, task_id)

  defp authored_by?(%Task{user_id: author_id}, %User{id: user_id}), do: user_id == author_id
end
