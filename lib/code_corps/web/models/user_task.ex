defmodule CodeCorps.Web.UserTask do
  @moduledoc """
  Represents a link record between a task and a user, indicating that
  the task was assigned to the user.
  """
  use CodeCorps.Web, :model

  @type t :: %__MODULE__{}

  schema "user_tasks" do
    belongs_to :task, CodeCorps.Web.Task
    belongs_to :user, CodeCorps.Web.User

    timestamps()
  end

  @permitted_create_attrs [:user_id, :task_id]
  @required_create_attrs @permitted_create_attrs

  @doc """
  Builds a changeset used to insert a record into the database
  """
  @spec create_changeset(CodeCorps.Web.UserTask.t, map) :: Ecto.Changeset.t
  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @permitted_create_attrs)
    |> validate_required(@required_create_attrs)
    |> assoc_constraint(:task)
    |> assoc_constraint(:user)
    |> unique_constraint(:user, name: :user_tasks_user_id_task_id_index)
  end

  @permitted_update_attrs [:user_id]
  @required_update_attrs @permitted_update_attrs

  @doc """
  Builds a changeset used to update an existing record in the database
  """
  @spec update_changeset(CodeCorps.Web.UserTask.t, map) :: Ecto.Changeset.t
  def update_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @permitted_update_attrs)
    |> validate_required(@required_update_attrs)
    |> assoc_constraint(:user)
  end
end
