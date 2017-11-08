defmodule CodeCorps.Task do
  use CodeCorps.Model

  import EctoOrdered

  alias CodeCorps.{Services.MarkdownRendererService, Task}
  alias Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "tasks" do
    field :archived, :boolean, default: false
    field :body, :string
    field :closed_at, :utc_datetime
    field :created_at, :utc_datetime
    field :created_from, :string, default: "code_corps"
    field :markdown, :string
    field :modified_at, :utc_datetime
    field :modified_from, :string, default: "code_corps"
    field :number, :integer, read_after_writes: true
    field :order, :integer
    field :status, :string, default: "open"
    field :title, :string

    field :position, :integer, virtual: true

    belongs_to :github_issue, CodeCorps.GithubIssue
    belongs_to :github_repo, CodeCorps.GithubRepo
    belongs_to :project, CodeCorps.Project
    belongs_to :task_list, CodeCorps.TaskList
    belongs_to :user, CodeCorps.User

    has_one :github_pull_request, through: [:github_issue, :github_pull_request]
    has_one :user_task, CodeCorps.UserTask

    has_many :comments, CodeCorps.Comment
    has_many :task_skills, CodeCorps.TaskSkill

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:archived, :title, :markdown, :task_list_id, :position])
    |> validate_required([:title])
    |> assoc_constraint(:task_list)
    |> handle_archived()
    |> MarkdownRendererService.render_markdown_to_html(:markdown, :body)
  end

  def handle_archived(changeset) do
    case get_field(changeset, :archived) do
      true ->
        changeset
        |> put_change(:task_list_id, nil)
        |> put_change(:order, nil)
      _ ->
        order_task(changeset)
    end
  end

  def order_task(changeset) do
    changeset
    |> validate_required([:task_list_id])
    |> apply_position()
    |> set_order(:position, :order, :task_list_id)
  end

  @spec create_changeset(struct, map) :: Ecto.Changeset.t
  def create_changeset(struct, %{} = params) do
    struct
    |> changeset(params)
    |> cast(params, [:github_repo_id, :project_id, :user_id])
    |> set_created_and_modified_at()
    |> validate_required([:project_id, :user_id])
    |> assoc_constraint(:github_repo)
    |> assoc_constraint(:project)
    |> assoc_constraint(:user)
    |> put_change(:status, "open")
    |> put_change(:modified_from, "code_corps")
  end

  @spec update_changeset(struct, map) :: Ecto.Changeset.t
  def update_changeset(struct, %{} = params) do
    struct
    |> changeset(params)
    |> cast(params, [:status])
    |> validate_inclusion(:status, statuses())
    |> set_closed_at()
    |> update_modified_at()
    |> maybe_assoc_with_repo(params)
    |> put_change(:modified_from, "code_corps")
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

  @spec maybe_assoc_with_repo(Changeset.t, map) :: Changeset.t
  defp maybe_assoc_with_repo(
    %Changeset{data: %Task{github_repo_id: nil}} = changeset,
    %{} = params) do

    changeset
    |> cast(params, [:github_repo_id])
    |> assoc_constraint(:github_repo)
  end
  defp maybe_assoc_with_repo(%Changeset{} = changeset, %{}), do: changeset
end
