defmodule CodeCorps.Post do
  use CodeCorps.Web, :model

  alias CodeCorps.MarkdownRenderer

  import CodeCorps.ModelHelpers

  schema "posts" do
    field :body, :string
    field :markdown, :string
    field :number, :integer
    field :post_type, :string
    field :state, :string
    field :status, :string, default: "open"
    field :title, :string

    belongs_to :project, CodeCorps.Project
    belongs_to :user, CodeCorps.User
    has_many :comments, CodeCorps.Comment

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :markdown, :post_type])
    |> validate_required([:title, :markdown, :post_type])
    |> validate_inclusion(:post_type, post_types)
    |> MarkdownRenderer.render_markdown_to_html(:markdown, :body)
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

  def update_changeset(struct, params) do
    struct
    |> changeset(params)
    |> cast(params, [:status])
    |> validate_inclusion(:status, statuses)
    |> put_change(:state, "edited")

  end

  defp post_types do
    ~w{ idea issue task }
  end

  defp statuses do
    ~w{ open closed }
  end

  def index_filters(query, params) do
    query |> project_filter(params)
  end

  def post_type_filters(query, params) do
    query |> post_type_filter(params)
  end

  def post_status_filters(query, params) do
    query |> post_status_filter(params)
  end

  def show_project_post_filters(query, params) do
    query
    |> number_as_id_filter(params)
    |> project_filter(params)
  end
end
