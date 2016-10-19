defmodule CodeCorps.Helpers.Policy do
  @moduledoc """
  Holds helpers for extracting record relationships and determining roles for
  authorization policies.
  """

  import Ecto.Query

  alias CodeCorps.{Organization, OrganizationMembership, Project, Repo, User}
  alias Ecto.Changeset

  @doc """
  Retrieves the specified user's membership record, from a `CodeCorps.Project` struct or an `Ecto.Changeset`,
  containing an `organization_id` field, or from a `CodeCorps.Organization` struct

  Returns `CodeCorps.OrganizationMembership`
  """
  def get_membership(nil, %User{}), do: nil
  def get_membership(%Changeset{changes: %{organization_id: organization_id}}, %User{id: user_id}), do: do_get_membership(organization_id, user_id)
  def get_membership(%Project{organization_id: organization_id}, %User{id: user_id}), do: do_get_membership(organization_id, user_id)
  def get_membership(%Organization{id: organization_id}, %User{id: user_id}), do: do_get_membership(organization_id, user_id)
  defp do_get_membership(organization_id, user_id) do
    OrganizationMembership
    |> where([m], m.member_id == ^user_id and m.organization_id == ^organization_id)
    |> Repo.one
  end

  @doc """
  Retrieves a project record, from a model struct, or an `Ecto.Changeset` containing a `project_id` field

  Returns `CodeCorps.Project`
  """
  def get_project(%{project_id: project_id}), do: Project |> Repo.get(project_id)
  def get_project(%Changeset{changes: %{project_id: project_id}}), do: Project |> Repo.get(project_id)
  def get_project(_), do: nil

  @doc """
  Retrieves the role field, from a `CodeCorps.OrganizationMembership` struct or an `Ecto.Changeset`

  Returns `:string`
  """
  def get_role(nil), do: nil
  def get_role(%OrganizationMembership{role: role}), do: role
  def get_role(%Changeset{} = changeset), do: changeset |> Changeset.get_field(:role)

  @doc """
  Determines if provided string is equal to "owner"
  """
  def owner?("owner"), do: true
  def owner?(_), do: false

  @doc """
  Determines if provided string is equal to one of `["admin", "owner"]`
  """
  def admin_or_higher?(role) when role in ["admin", "owner"], do: true
  def admin_or_higher?(_), do: false

  @doc """
  Determines if provided string is equal to one of `["contributor", "admin", "owner"]`
  """
  def contributor_or_higher?(role) when role in ["contributor", "admin", "owner"], do: true
  def contributor_or_higher?(_), do: false
end
