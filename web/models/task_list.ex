defmodule CodeCorps.TaskList do
  use CodeCorps.Web, :model
  import EctoOrdered

  alias CodeCorps.TaskList

  @type t :: %__MODULE__{}

  schema "task_lists" do
    field :inbox, :boolean, default: false
    field :name, :string
    field :order, :integer
    field :position, :integer, virtual: true

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
        inbox: false,
        name: "In Progress",
        position: 3
      }, %{
        inbox: false,
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
    |> cast(params, [:inbox])
    |> changeset(params)
    |> validate_required([:inbox])
  end
end
