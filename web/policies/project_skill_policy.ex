defmodule CodeCorps.ProjectSkillPolicy do
  import CodeCorps.Helpers.Policy,
    only: [get_project: 1, get_membership: 2, get_role: 1, admin_or_higher?: 1]

  alias CodeCorps.ProjectSkill
  alias CodeCorps.User
  alias Ecto.Changeset

  def create?(%User{admin: true}, %Changeset{}), do: true
  def create?(%User{} = user, %Changeset{} = changeset) do
    changeset |> get_project |> get_membership(user) |> get_role |> admin_or_higher?
  end

  def delete?(%User{admin: true}, %ProjectSkill{}), do: true
  def delete?(%User{} = user, %ProjectSkill{} = project_category) do
    project_category |> get_project |> get_membership(user) |> get_role |> admin_or_higher?
  end
end
