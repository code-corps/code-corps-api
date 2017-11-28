defmodule CodeCorps.Policy.Organization do
  @moduledoc ~S"""
  Authorization policies for performing actions on `Organization` records
  """
  import CodeCorps.Policy.Helpers, only: [owned_by?: 2]

  import Ecto.Query

  alias CodeCorps.{Organization, OrganizationInvite, Repo, User}

  @doc ~S"""
  Returns a boolean indicating if the specified user is allowed to create the
  organization specified by a map of attributes.
  """
  @spec create?(User.t, map) :: boolean
  def create?(%User{admin: true}, %{}), do: true
  def create?(%User{}, %{"invite_code" => invite_code}) do
    case invite_code |> get_invite() do
      nil -> false
      _invite -> true
    end
  end
  def create?(%User{}, %{}), do: false

  @doc ~S"""
  Returns a boolean indicating if the specified user is allowed to update the
  specified organization.
  """
  @spec update?(User.t, Organization.t) :: boolean
  def update?(%User{admin: true}, %Organization{}), do: true
  def update?(%User{} = user, %Organization{} = organization), do: organization |> owned_by?(user)

  @spec get_invite(String.t) :: OrganizationInvite.t | nil
  defp get_invite(code) do
    OrganizationInvite
    |> where([oi], is_nil(oi.organization_id))
    |> Repo.get_by(code: code)
  end
end
