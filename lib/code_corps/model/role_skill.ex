defmodule CodeCorps.RoleSkill do
  use CodeCorps.Model

  @type t :: %__MODULE__{}

  schema "role_skills" do
    field :cat, :integer

    belongs_to :role, CodeCorps.Role
    belongs_to :skill, CodeCorps.Skill

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec create_changeset(CodeCorps.RoleSkill.t, map) :: Ecto.Changeset.t
  def create_changeset(struct, params \\ %{}) do
    changeset(struct, params)
  end

  @doc """
  Builds a changeset for importing a category.
  """
  @spec import_changeset(CodeCorps.RoleSkill.t, map) :: Ecto.Changeset.t
  def import_changeset(struct, params \\ %{}) do
    struct
    |> changeset(params)
    |> cast(params, [:cat])
    |> validate_inclusion(:cat, cats())
  end

  @spec changeset(CodeCorps.RoleSkill.t, map) :: Ecto.Changeset.t
  defp changeset(struct, params) do
    struct
    |> cast(params, [:role_id, :skill_id])
    |> validate_required([:role_id, :skill_id])
    |> assoc_constraint(:role)
    |> assoc_constraint(:skill)
    |> unique_constraint(:role_id, name: :index_projects_on_role_id_skill_id)
  end

  defp cats do
    [1, 2, 3, 4, 5, 6]
  end
end
