defmodule CodeCorps.Comment do
  use CodeCorps.Web, :model

  alias CodeCorps.MarkdownRenderer

  import CodeCorps.ModelHelpers

  schema "comments" do
    field :body, :string
    field :markdown, :string

    belongs_to :user, CodeCorps.User
    belongs_to :post, CodeCorps.Post

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
    |> cast(params, [:post_id, :user_id])
    |> validate_required([:post_id, :user_id])
    |> assoc_constraint(:post)
    |> assoc_constraint(:user)
  end

  def index_filters(query, params) do
    query |> post_filter(params)
  end
end
