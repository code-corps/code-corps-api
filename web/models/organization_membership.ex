defmodule CodeCorps.OrganizationMembership do
  @moduledoc """
  Represents a membership of a user in an organization.
  """

  use CodeCorps.Web, :model

  schema "organization_memberships" do
    field :role, :string

    belongs_to :organization, CodeCorps.Organization
    belongs_to :member, CodeCorps.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`, for creating a record.
  The membership role is strictly set to "pending" by the system, regardless of parameters
  """
  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:member_id, :organization_id])
    |> validate_required([:member_id, :organization_id])
    |> assoc_constraint(:member)
    |> assoc_constraint(:organization)
    |> put_change(:role, "pending")
  end

  @doc """
  Builds a changeset based on the `struct` and `params`, for updating a record.
  """
  def update_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:role])
    |> validate_required([:role])
    |> validate_inclusion(:role, roles)
  end

  defp roles do
    ~w{ pending contributor admin owner }
  end
end
