defmodule CodeCorps.TaskList do
  use CodeCorps.Model
  import EctoOrdered

  alias CodeCorps.TaskList

  @type t :: %__MODULE__{}

  schema "task_lists" do
    field :done, :boolean, default: false
    field :inbox, :boolean, default: false
    field :name, :string
    field :order, :integer
    field :position, :integer, virtual: true
    field :pull_requests, :boolean, default: false

    belongs_to :project, CodeCorps.Project
    has_many :tasks, CodeCorps.Task

    timestamps()
  end

  def default_task_lists() do
    [
      %{
        inbox: true,
        name: "Inbox",
        position: 1
      }, %{
        inbox: false,
        name: "Backlog",
        position: 2
      }, %{
        pull_requests: true,
        name: "In Progress",
        position: 3
      }, %{
        done: true,
        name: "Done",
        position: 4
      }
    ] |> Enum.map(fn (params) -> create_changeset(%TaskList{}, params) end)
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

  def create_changeset(struct, params) do
    struct
    |> cast(params, [:done, :inbox, :pull_requests])
    |> changeset(params)
    |> validate_required([:done, :inbox, :pull_requests])
    |> unique_constraint(:done, name: "task_lists_project_id_done_index")
    |> unique_constraint(:inbox, name: "task_lists_project_id_inbox_index")
    |> unique_constraint(:pull_requests, name: "task_lists_project_id_pull_requests_index")
  end
end
