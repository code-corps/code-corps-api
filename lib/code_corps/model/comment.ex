defmodule CodeCorps.Comment do
  use CodeCorps.Model

  alias CodeCorps.Services.MarkdownRendererService

  @type t :: %__MODULE__{}

  schema "comments" do
    field :body, :string
    field :created_at, :utc_datetime
    field :created_from, :string, default: "code_corps"
    field :markdown, :string
    field :modified_at, :utc_datetime
    field :modified_from, :string, default: "code_corps"

    belongs_to :github_comment, CodeCorps.GithubComment
    belongs_to :user, CodeCorps.User
    belongs_to :task, CodeCorps.Task

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:markdown])
    |> validate_required([:markdown])
    |> MarkdownRendererService.render_markdown_to_html(:markdown, :body)
  end

  def create_changeset(struct, params) do
    struct
    |> changeset(params)
    |> cast(params, [:task_id, :user_id])
    |> set_created_and_modified_at()
    |> validate_required([:task_id, :user_id])
    |> assoc_constraint(:task)
    |> assoc_constraint(:user)
    |> put_change(:modified_from, "code_corps")
  end

  def update_changeset(struct, params) do
    struct
    |> changeset(params)
    |> update_modified_at()
    |> put_change(:modified_from, "code_corps")
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
