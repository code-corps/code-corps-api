defmodule CodeCorps.Policy.Project do
  import CodeCorps.Policy.Helpers,
    only: [get_organization: 1, owned_by?: 2, administered_by?: 2]

  alias CodeCorps.{Project, User}

  @spec create?(User.t, map) :: boolean
  def create?(%User{} = user, params) do
    params |> get_organization() |> owned_by?(user)
  end

  @spec update?(User.t, Project.t, map) :: boolean
  def update?(%User{admin: true}, %Project{}, %{}), do: true
  def update?(%User{}, %Project{}, %{"approved" => true}), do: false
  def update?(%User{} = user, %Project{} = project, _), do: project |> administered_by?(user)
end
