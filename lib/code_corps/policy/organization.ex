defmodule CodeCorps.Policy.Organization do
  @moduledoc ~S"""
  Authorization policies for performing actions on `Organization` records
  """  
  import CodeCorps.Policy.Helpers,
    only: [owned_by?: 2]

  alias CodeCorps.{Organization, User}

  def create?(%User{admin: true}), do: true
  def create?(%User{admin: false}), do: false

  def update?(%User{admin: true}, %Organization{}), do: true
  def update?(%User{} = user, %Organization{} = organization), do: organization |> owned_by?(user)
end
