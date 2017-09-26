defmodule CodeCorps.Policy.ProjectSkill do
  import CodeCorps.Policy.Helpers, only: [get_project: 1, administered_by?: 2]

  alias CodeCorps.{ProjectSkill, User}

  @spec create?(User.t, map) :: boolean
  def create?(%User{} = user, %{} = params) do
    params |> get_project |> administered_by?(user)
  end

  @spec delete?(User.t, ProjectSkill.t) :: boolean
  def delete?(%User{} = user, %ProjectSkill{} = project_skill) do
    project_skill |> get_project |> administered_by?(user)
  end
end
