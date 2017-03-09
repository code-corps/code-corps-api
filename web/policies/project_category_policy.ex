defmodule CodeCorps.ProjectCategoryPolicy do
  import CodeCorps.Helpers.Policy, only: [get_project: 1, administered_by?: 2]

  alias CodeCorps.{ProjectCategory, User}
  alias Ecto.Changeset

  def create?(%User{} = user, %Changeset{} = changeset) do
    changeset |> get_project |> administered_by?(user)
  end

  def delete?(%User{} = user, %ProjectCategory{} = project_category) do
    project_category |> get_project |> administered_by?(user)
  end
end
