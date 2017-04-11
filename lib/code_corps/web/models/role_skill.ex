defmodule CodeCorps.Web.RoleSkill do
  use CodeCorps.Web, :model

  @type t :: %__MODULE__{}

  schema "role_skills" do
    field :cat, :integer

    belongs_to :role, CodeCorps.Web.Role
    belongs_to :skill, CodeCorps.Web.Skill

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec changeset(CodeCorps.Web.RoleSkill.t, map) :: Ecto.Changeset.t
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:role_id, :skill_id])
    |> validate_required([:role_id, :skill_id])
    |> assoc_constraint(:role)
    |> assoc_constraint(:skill)
    |> unique_constraint(:role_id, name: :index_projects_on_role_id_skill_id)
  end

  @doc """
  Builds a changeset for importing a category.
  """
  @spec import_changeset(CodeCorps.Web.RoleSkill.t, map) :: Ecto.Changeset.t
  def import_changeset(struct, params) do
    struct
    |> changeset(params)
    |> cast(params, [:cat])
    |> validate_inclusion(:cat, cats())
  end

  defp cats do
    [1, 2, 3, 4, 5, 6]
  end
end
