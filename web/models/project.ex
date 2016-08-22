defmodule CodeCorps.Project do
  @moduledoc """
  Represents a project on Code Corps, e.g. the "Code Corps" project itself.
  """

  use Arc.Ecto.Schema
  use CodeCorps.Web, :model

  alias CodeCorps.MarkdownRenderer

  import CodeCorps.Base64ImageUploader
  import CodeCorps.ModelHelpers
  import CodeCorps.Validators.SlugValidator

  schema "projects" do
    field :base64_icon_data, :string, virtual: true
    field :description, :string
    field :icon, CodeCorps.ProjectIcon.Type
    field :icon_large_url, :string
    field :icon_thumb_url, :string
    field :long_description_body, :string
    field :long_description_markdown, :string
    field :slug, :string
    field :title, :string

    belongs_to :organization, CodeCorps.Organization

    timestamps()
  end

  def changeset(struct, params) do
    struct
  	|> cast(params, [:title, :description, :long_description_markdown, :organization_id, :base64_icon_data])
    |> validate_required(:title)
    |> generate_slug(:title, :slug)
    |> validate_slug(:slug)
    |> unique_constraint(:slug, name: :index_projects_on_slug)
    |> MarkdownRenderer.render_markdown_to_html(:long_description_markdown, :long_description_body)
    |> upload_image(:base64_icon_data, :icon)
  end

  @doc """
  Builds a changeset for creating a project.
  """
  def create_changeset(struct, params) do
    struct
    |> changeset(params)
    |> generate_slug(:title, :slug)
    |> validate_required([:slug])
    |> validate_slug(:slug)
  end
end
