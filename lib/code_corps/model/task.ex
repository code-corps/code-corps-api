defmodule CodeCorps.Task do
  use CodeCorps.Model

  import EctoOrdered

  alias CodeCorps.Services.MarkdownRendererService

  @type t :: %__MODULE__{}

  schema "tasks" do
    field :body, :string
    field :markdown, :string
    field :number, :integer, read_after_writes: true
    field :order, :integer
    field :status, :string, default: "open"
    field :title, :string
    field :github_issue_number, :integer
    field :task_created_at, :naive_datetime
    field :task_updated_at, :naive_datetime

    field :position, :integer, virtual: true

    belongs_to :github_repo, CodeCorps.GithubRepo
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
    |> validate_required([:title, :task_list_id])
    |> assoc_constraint(:task_list)
    |> apply_position()
    |> set_order(:position, :order, :task_list_id)
    |> MarkdownRendererService.render_markdown_to_html(:markdown, :body)
  end

  @spec create_changeset(struct, map) :: Ecto.Changeset.t
  def create_changeset(struct, %{} = params) do
    struct
    |> changeset(params)
    |> cast(params, [:project_id, :user_id, :github_repo_id])
    |> validate_required([:project_id, :user_id])
    |> assoc_constraint(:project)
    |> assoc_constraint(:user)
    |> assoc_constraint(:github_repo)
    |> set_datetime(:task_created_at)
    |> put_change(:status, "open")
  end

  def update_changeset(struct, params) do
    struct
    |> changeset(params)
    |> cast(params, [:status])
    |> set_datetime(:task_updated_at)
    |> validate_inclusion(:status, statuses())
  end

  def apply_position(changeset) do
    case get_field(changeset, :position) do
      nil ->
        put_change(changeset, :position, 0)
      _ -> changeset
    end
  end

  defp set_datetime(changeset, field) do
    put_change(changeset, field, NaiveDateTime.utc_now)
  end

  defp statuses do
    ~w{ open closed }
  end
end
