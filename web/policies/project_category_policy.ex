defmodule CodeCorps.ProjectCategoryPolicy do
  import CodeCorps.Helpers.Policy,
    only: [get_project: 1, get_membership: 2, get_role: 1, admin_or_higher?: 1]

  alias CodeCorps.ProjectCategory
  alias CodeCorps.User
  alias Ecto.Changeset

  def create?(%User{admin: true}, %Changeset{}), do: true
  def create?(%User{} = user, %Changeset{} = changeset) do
    changeset |> get_project |> get_membership(user) |> get_role |> admin_or_higher?
  end

  def delete?(%User{admin: true}, %ProjectCategory{}), do: true
  def delete?(%User{} = user, %ProjectCategory{} = project_category) do
    project_category |> get_project |> get_membership(user) |> get_role |> admin_or_higher?
  end
end
