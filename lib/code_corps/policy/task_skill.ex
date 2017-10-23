defmodule CodeCorps.Policy.TaskSkill do
  @moduledoc """
  Represents an authorization policy for performing actions on TaskSkill records.
  Used to authorize a controller action.
  """

  import CodeCorps.Policy.Helpers,
    only: [
      contributed_by?: 2,
      get_project: 1,
      get_task: 1,
      task_authored_by?: 2
    ]

  alias CodeCorps.{TaskSkill, User}

  @spec create?(User.t, map) :: boolean
  def create?(%User{} = user, %{} = params) do
    cond do
      params |> get_task |> task_authored_by?(user) -> true
      params |> get_task |> get_project |> contributed_by?(user) -> true
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
