defmodule CodeCorps.Web.TaskSkill do
  @moduledoc """
  Represents a link record between a task and a skill, indicating that
  for a user to be suitable to work on a task, they need to posses skills
  associated with that task.
  """
  use CodeCorps.Web, :model

  @type t :: %__MODULE__{}

  schema "task_skills" do
    belongs_to :skill, CodeCorps.Web.Skill
    belongs_to :task, CodeCorps.Web.Task

    timestamps()
  end

  @permitted_attrs [:skill_id, :task_id]
  @required_attrs @permitted_attrs

  @doc """
  Builds a changeset used to insert a record into the database
  """
  @spec create_changeset(CodeCorps.Web.TaskSkill.t, map) :: Ecto.Changeset.t
  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @permitted_attrs)
    |> validate_required(@required_attrs)
    |> assoc_constraint(:task)
    |> assoc_constraint(:skill)
    |> unique_constraint(:skill, name: :task_skills_task_id_skill_id_index)
  end
end
