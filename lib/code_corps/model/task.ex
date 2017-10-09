defmodule CodeCorps.Task do
  use CodeCorps.Model

  import EctoOrdered

  alias CodeCorps.Services.MarkdownRendererService
  alias Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "tasks" do
    field :archived, :boolean, default: false
    field :body, :string
    field :closed_at, :utc_datetime
    field :created_at, :utc_datetime
    field :created_from, :string, default: "code_corps"
    field :github_issue_number, :integer
    field :markdown, :string
    field :modified_at, :utc_datetime
    field :modified_from, :string, default: "code_corps"
    field :number, :integer, read_after_writes: true
    field :order, :integer
    field :status, :string, default: "open"
    field :title, :string

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
    |> set_created_and_modified_at()
    |> validate_required([:project_id, :user_id])
    |> assoc_constraint(:project)
    |> assoc_constraint(:user)
    |> assoc_constraint(:github_repo)
    |> put_change(:status, "open")
  end

  def update_changeset(struct, params) do
    struct
    |> changeset(params)
    |> cast(params, [:archived, :status])
    |> validate_inclusion(:status, statuses())
    |> set_closed_at()
    |> update_modified_at()
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

  defp set_closed_at(changeset) do
    case changeset do
      %Changeset{valid?: true, changes: %{status: "closed"}} ->
        put_change(changeset, :closed_at, DateTime.utc_now)
      %Changeset{valid?: true, changes: %{status: "open"}} ->
        put_change(changeset, :closed_at, nil)
      _ ->
        changeset
    end
  end

  defp set_created_and_modified_at(changeset) do
    now = DateTime.utc_now
    changeset
    |> put_change(:created_at, now)
    |> put_change(:modified_at, now)
  end

  defp update_modified_at(changeset) do
    put_change(changeset, :modified_at, DateTime.utc_now)
  end
end
