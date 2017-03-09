defmodule CodeCorps.TaskSkillPolicy do
  @moduledoc """
  Represents an authorization policy for performing actions on TaskSkill records.
  Used to authorize a controller action.
  """

  import CodeCorps.Helpers.Policy,
    only: [
      contributed_by?: 2,
      get_project: 1,
      get_task: 1,
      task_authored_by?: 2
    ]

  alias CodeCorps.{TaskSkill, User}
  alias Ecto.Changeset

  @spec create?(User.t, Changeset.t) :: boolean
  def create?(%User{} = user, %Changeset{} = changeset) do
    cond do
      changeset |> get_task |> task_authored_by?(user) -> true
      changeset |> get_task |> get_project |> contributed_by?(user) -> true
      true -> false
    end
  end

  @spec delete?(User.t, TaskSkill.t) :: boolean
  def delete?(%User{} = user, %TaskSkill{} = task_skill) do
    cond do
      task_skill |> get_task |> task_authored_by?(user) -> true
      task_skill |> get_task |> get_project |> contributed_by?(user) -> true
      true -> false
    end
  end
end
