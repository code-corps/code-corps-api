defmodule CodeCorps.ProjectPolicy do
  import CodeCorps.Helpers.Policy,
    only: [get_membership: 2, get_role: 1, admin_or_higher?: 1, owner?: 1]

  alias CodeCorps.Project
  alias CodeCorps.User
  alias Ecto.Changeset

  # TODO: ProjectPolicy needs testing for the case of user being at least admin
  # in project organization

  def create?(%User{admin: true}, %Changeset{}), do: true
  def create?(%User{} = user, %Changeset{} = changeset), do: changeset |> get_membership(user) |> get_role |> admin_or_higher?

  def update?(%User{admin: true}, %Project{}), do: true
  def update?(%User{} = user, %Project{} = project), do: project |> get_membership(user) |> get_role |> admin_or_higher?

  def stripe_auth?(%User{admin: true}, %Project{}), do: true
  def stripe_auth?(%User{} = user, %Project{} = project), do: project |> get_membership(user) |> get_role |> owner?
end
