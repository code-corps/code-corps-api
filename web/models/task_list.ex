defmodule CodeCorps.TaskList do
  use CodeCorps.Web, :model
  import EctoOrdered

  alias CodeCorps.TaskList

  schema "task_lists" do
    field :name, :string
    field :position, :integer, virtual: true
    field :order, :integer

    belongs_to :project, CodeCorps.Project
    has_many :tasks, CodeCorps.Task

    timestamps()
  end

  def default_task_lists() do
    task_list_data = [
      %{
        name: "Inbox",
        position: 1
      }, %{
        name: "Backlog",
        position: 2
      }, %{
        name: "In Progress",
        position: 3
      }, %{
        name: "Done",
        position: 4
      }
    ]

    for task_list <- task_list_data do
      TaskList.changeset(%TaskList{}, task_list)
    end
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :position])
    |> validate_required([:name, :position])
    |> set_order(:position, :order, :project_id)
  end
end
