defmodule CodeCorps.UserRole do
  use CodeCorps.Model

  @type t :: %__MODULE__{}

  schema "user_roles" do
    belongs_to :user, CodeCorps.User
    belongs_to :role, CodeCorps.Role

    timestamps(type: :utc_datetime)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :role_id])
    |> validate_required([:user_id, :role_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:role)
    |> unique_constraint(:user_id, name: :index_projects_on_user_id_role_id)
  end
end
