defmodule CodeCorps.Comment do
  use CodeCorps.Web, :model

  alias CodeCorps.Services.MarkdownRendererService

  @type t :: %__MODULE__{}

  schema "comments" do
    field :body, :string
    field :markdown, :string
    field :github_id, :integer

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
    |> validate_required([:task_id, :user_id])
    |> assoc_constraint(:task)
    |> assoc_constraint(:user)
  end

  @doc """
  Builds a changeset for creating a comment that has a connected GitHub comment.
  """
  def github_create_changeset(struct, params) do
    struct
    |> create_changeset(params)
    |> cast(params, [:github_id])
  end
end
