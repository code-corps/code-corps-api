defmodule CodeCorps.Policy.ProjectCategory do
  import CodeCorps.Policy.Helpers, only: [get_project: 1, administered_by?: 2]

  alias CodeCorps.{ProjectCategory, User}

  @spec create?(User.t, map) :: boolean
  def create?(%User{} = user, %{} = params) do
    params |> get_project |> administered_by?(user)
  end

  @spec delete?(User.t, ProjectCategory.t) :: boolean
  def delete?(%User{} = user, %ProjectCategory{} = project_category) do
    project_category |> get_project |> administered_by?(user)
  end
end
