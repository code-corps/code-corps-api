defmodule CodeCorps.Policy.Project do
  import CodeCorps.Policy.Helpers,
    only: [get_organization: 1, owned_by?: 2, administered_by?: 2]

  alias CodeCorps.{Project, User}
  alias Ecto.Changeset

  @spec create?(User.t, map) :: boolean
  def create?(%User{} = user, params) do
    params |> get_organization() |> owned_by?(user)
  end

  @spec update?(User.t, Project.t) :: boolean
  def update?(%User{} = user, %Project{} = project), do: project |> administered_by?(user)
end
