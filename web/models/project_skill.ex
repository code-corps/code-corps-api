defmodule CodeCorps.ProjectSkill do
  use CodeCorps.Web, :model

  schema "project_skills" do
    belongs_to :project, CodeCorps.Project
    belongs_to :skill, CodeCorps.Skill

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:project_id, :skill_id])
    |> validate_required([:project_id, :skill_id])
    |> assoc_constraint(:project)
    |> assoc_constraint(:skill)
    |> unique_constraint(:project_id, name: :index_projects_on_project_id_skill_id)
  end
end
