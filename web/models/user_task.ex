defmodule CodeCorps.UserTask do
  @moduledoc """
  Represents a link record between a task and a user, indicating that
  the task was assigned to the user.
  """
  use CodeCorps.Web, :model

  @type t :: %__MODULE__{}

  schema "user_tasks" do
    belongs_to :user, CodeCorps.Skill
    belongs_to :task, CodeCorps.Task

    timestamps()
  end

  @permitted_attrs [:user_id, :task_id]
  @required_attrs @permitted_attrs

  @doc """
  Builds a changeset used to insert a record into the database
  """
  @spec create_changeset(CodeCorps.UserTask.t, map) :: Ecto.Changeset.t
  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @permitted_attrs)
    |> validate_required(@required_attrs)
    |> assoc_constraint(:task)
    |> assoc_constraint(:user)
    |> unique_constraint(:user, name: :user_tasks_user_id_task_id_index)
  end
end
