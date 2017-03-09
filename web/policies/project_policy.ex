defmodule CodeCorps.ProjectPolicy do
  import CodeCorps.Helpers.Policy,
    only: [get_organization: 1, owned_by?: 2, administered_by?: 2]

  alias CodeCorps.{Project, User}
  alias Ecto.Changeset

  @spec create?(User.t, Changeset.t) :: boolean
  def create?(%User{} = user, %Changeset{} = changeset) do
    changeset |> get_organization() |> owned_by?(user)
  end

  @spec update?(User.t, Project.t) :: boolean
  def update?(%User{} = user, %Project{} = project), do: project |> administered_by?(user)
end
