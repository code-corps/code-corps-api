defmodule CodeCorps.Post do
  use CodeCorps.Web, :model

  alias CodeCorps.MarkdownRenderer

  schema "posts" do
    field :body, :string
    field :markdown, :string
    field :number, :integer
    field :post_type, :string
    field :status, :string, default: "open"
    field :title, :string

    belongs_to :project, CodeCorps.Project
    belongs_to :user, CodeCorps.User

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :markdown, :post_type, :status, :project_id])
    |> validate_required([:title, :markdown, :post_type, :status])
    |> validate_inclusion(:post_type, post_types)
    |> validate_inclusion(:status, statuses)
    |> assoc_constraint(:project)
    |> MarkdownRenderer.render_markdown_to_html(:markdown, :body)
  end

  def create_changeset(struct, params) do
    struct
    |> changeset(params)
    |> cast(params, [:project_id, :user_id])
    |> validate_required([:project_id, :user_id])
    |> assoc_constraint(:project)
    |> assoc_constraint(:user)
  end

  defp post_types do
    ~w{ idea issue task }
  end

  defp statuses do
    ~w{ open closed }
  end
end
