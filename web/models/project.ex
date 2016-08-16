defmodule CodeCorps.Project do
  @moduledoc """
  Represents a project on Code Corps, e.g. the "Code Corps" project itself.
  """

  use CodeCorps.Web, :model

  alias CodeCorps.MarkdownRenderer

  import CodeCorps.ModelHelpers
  import CodeCorps.Validators.SlugValidator

  schema "projects" do
    field :description, :string
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
  	|> cast(params, [:title, :description, :long_description_markdown, :organization_id])
    |> validate_required(:title)
    |> generate_slug(:title, :slug)
    |> validate_slug(:slug)
    |> unique_constraint(:slug, name: :index_projects_on_slug)
    |> add_project_icons(Map.get(params, :base64_icon_data))
    |> MarkdownRenderer.render_markdown_to_html(:long_description_markdown, :long_description_body)
  end

  defp add_project_icons(changeset, nil), do: changeset
  defp add_project_icons(changeset, _base64_icon_data) do
    # TODO: Deal with base64 conversion to image file
    # TODO: Deal with image file upload
    changeset
  end
end
