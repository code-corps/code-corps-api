defmodule CodeCorps.RoleSkill do
  use CodeCorps.Web, :model

  import CodeCorps.ModelHelpers

  schema "role_skills" do
    belongs_to :role, CodeCorps.Role
    belongs_to :skill, CodeCorps.Skill

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:role_id, :skill_id])
    |> validate_required([:role_id, :skill_id])
    |> assoc_constraint(:role)
    |> assoc_constraint(:skill)
    |> unique_constraint(:role_id, name: :index_projects_on_role_id_skill_id)
  end

  def index_filters(query, params) do
    query |> id_filter(params)
  end
end
