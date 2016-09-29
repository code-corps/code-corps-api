defmodule CodeCorps.Comment do
  use CodeCorps.Web, :model

  alias CodeCorps.MarkdownRenderer

  import CodeCorps.ModelHelpers

  schema "comments" do
    field :body, :string
    field :markdown, :string

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
    |> MarkdownRenderer.render_markdown_to_html(:markdown, :body)
  end

  def create_changeset(struct, params) do
    struct
    |> changeset(params)
    |> cast(params, [:task_id, :user_id])
    |> validate_required([:task_id, :user_id])
    |> assoc_constraint(:task)
    |> assoc_constraint(:user)
  end

  def index_filters(query, params) do
    query |> task_filter(params)
  end
end
