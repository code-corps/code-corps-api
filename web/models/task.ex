defmodule CodeCorps.Task do
  use CodeCorps.Web, :model

  import EctoOrdered

  alias CodeCorps.Services.MarkdownRendererService

  @type t :: %__MODULE__{}

  schema "tasks" do
    field :body, :string
    field :markdown, :string
    field :number, :integer, read_after_writes: true
    field :order, :integer
    field :state, :string
    field :status, :string, default: "open"
    field :title, :string
    field :github_id, :integer

    field :position, :integer, virtual: true

    belongs_to :project, CodeCorps.Project
    belongs_to :task_list, CodeCorps.TaskList
    belongs_to :user, CodeCorps.User

    has_one :user_task, CodeCorps.UserTask

    has_many :comments, CodeCorps.Comment
    has_many :task_skills, CodeCorps.TaskSkill

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :markdown, :task_list_id, :position])
    |> validate_required([:title, :markdown, :task_list_id])
    |> assoc_constraint(:task_list)
    |> apply_position()
    |> set_order(:position, :order, :task_list_id)
    |> MarkdownRendererService.render_markdown_to_html(:markdown, :body)
  end

  def create_changeset(struct, params) do
    struct
    |> changeset(params)
    |> cast(params, [:project_id, :user_id])
    |> validate_required([:project_id, :user_id])
    |> assoc_constraint(:project)
    |> assoc_constraint(:user)
    |> put_change(:state, "published")
    |> put_change(:status, "open")
  end

  @doc """
  Builds a changeset for creating a task that has a connected GitHub issue.
  """
  def github_create_changeset(struct, params) do
    struct
    |> create_changeset(params)
    |> cast(params, [:github_id])
    |> validate_required([:github_id])
  end

  def update_changeset(struct, params) do
    struct
    |> changeset(params)
    |> cast(params, [:status])
    |> validate_inclusion(:status, statuses())
    |> put_change(:state, "edited")
  end

  def apply_position(changeset) do
    case get_field(changeset, :position) do
      nil ->
        put_change(changeset, :position, 0)
      _ -> changeset
    end
  end

  defp statuses do
    ~w{ open closed }
  end
end
