defmodule CodeCorps.Web.ProjectUser do
  @moduledoc """
  Represents a membership of a user in a project.
  """

  use CodeCorps.Web, :model

  @type t :: %__MODULE__{}

  schema "project_users" do
    field :role, :string

    belongs_to :project, CodeCorps.Web.Project
    belongs_to :user, CodeCorps.Web.User

    timestamps()
  end


  @doc """
  Builds a changeset to create a pending membership
  """
  def create_changeset(struct, params \\ %{}) do
    struct
    |> changeset(params)
    |> put_change(:role, "pending")
  end

  @doc """
  Builds a changeset to create an owner membership
  """
  def create_owner_changeset(struct, params \\ %{}) do
    struct
    |> changeset(params)
    |> put_change(:role, "owner")
  end

  # Builds a base changeset for inserting a new record into the database
  defp changeset(struct, params) do
    struct
    |> cast(params, [:user_id, :project_id])
    |> validate_required([:user_id, :project_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:project)
    |> unique_constraint(:project, name: :project_users_user_id_project_id_index)
  end

  @doc """
  Builds a changeset for updating a record. Only the role can be updated.
  """
  def update_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:role])
    |> validate_required([:role])
    |> validate_inclusion(:role, roles())
  end

  defp roles do
    ~w{ pending contributor admin owner }
  end
end
