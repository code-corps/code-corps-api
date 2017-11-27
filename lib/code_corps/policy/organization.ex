defmodule CodeCorps.Policy.Organization do
  @moduledoc ~S"""
  Authorization policies for performing actions on `Organization` records
  """
  import CodeCorps.Policy.Helpers,
    only: [owned_by?: 2, get_organization_invite: 1]

  alias CodeCorps.{Organization, User}

  def create?(%User{admin: true}, %{}), do: true
  def create?(%User{}, %{} = params) do
    case get_organization_invite(params) do
      nil -> false
      _ -> true
    end
  end
  def create?(%{}, %{}), do: false

  def update?(%User{admin: true}, %Organization{}), do: true
  def update?(%User{} = user, %Organization{} = organization), do: organization |> owned_by?(user)
end
