defmodule CodeCorps.UserTaskPolicy do
  @moduledoc """
  Represents an authorization policy for performing actions on UserTask records.
  Used to authorize a controller action.
  """
  import CodeCorps.Helpers.Policy,
    only: [
      contributor_or_higher?: 1,
      get_membership: 2,
      get_project: 1,
      get_role: 1,
      get_task: 1,
      task_authored_by?: 2
    ]

  alias CodeCorps.{User, UserTask}
  alias Ecto.Changeset

  @spec create?(User.t, Changeset.t) :: boolean
  def create?(%User{} = user, %Changeset{} = changeset) do
    cond do
      changeset |> get_task |> get_project |> get_membership(user) |> get_role |> contributor_or_higher? -> true
      changeset |> get_task |> task_authored_by?(user) -> true
      true -> false
    end
  end

  @spec update?(User.t, UserTask.t) :: boolean
  def update?(%User{} = user, %UserTask{} = user_task) do
    cond do
      user_task |> get_task |> get_project |> get_membership(user) |> get_role |> contributor_or_higher? -> true
      user_task |> get_task |> task_authored_by?(user) -> true
      true -> false
    end
  end

  @spec delete?(User.t, UserTask.t) :: boolean
  def delete?(%User{} = user, %UserTask{} = user_task) do
    cond do
      user_task |> get_task |> get_project |> get_membership(user) |> get_role |> contributor_or_higher? -> true
      user_task |> get_task |> task_authored_by?(user) -> true
      true -> false
    end
  end
end
