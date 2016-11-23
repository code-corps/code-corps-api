defmodule CodeCorps.Project do
  @moduledoc """
  Represents a project on Code Corps, e.g. the "Code Corps" project itself.
  """

  use Arc.Ecto.Schema
  use CodeCorps.Web, :model
  import CodeCorps.Base64ImageUploader
  import CodeCorps.Helpers.Slug
  import CodeCorps.Validators.SlugValidator
  alias CodeCorps.MarkdownRenderer

  schema "projects" do
    field :base64_icon_data, :string, virtual: true
    field :description, :string
    field :icon, CodeCorps.ProjectIcon.Type
    field :long_description_body, :string
    field :long_description_markdown, :string
    field :slug, :string
    field :title, :string

    belongs_to :organization, CodeCorps.Organization
    has_one :stripe_connect_plan, CodeCorps.StripeConnectPlan

    has_many :donation_goals, CodeCorps.DonationGoal
    has_many :project_categories, CodeCorps.ProjectCategory
    has_many :project_skills, CodeCorps.ProjectSkill
    has_many :tasks, CodeCorps.Task

    has_many :categories, through: [:project_categories, :category]
    has_many :skills, through: [:project_skills, :skill]

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:title, :description, :long_description_markdown, :base64_icon_data])
    |> validate_required(:title)
    |> generate_slug(:title, :slug)
    |> validate_slug(:slug)
    |> unique_constraint(:slug, name: :index_projects_on_slug)
    |> MarkdownRenderer.render_markdown_to_html(:long_description_markdown, :long_description_body)
    |> upload_image(:base64_icon_data, :icon)
  end

  @doc """
  Builds a changeset for creating a project.
  """
  def create_changeset(struct, params) do
    struct
    |> cast(params, [:organization_id])
    |> changeset(params)

  end

  @doc """
  Builds a changeset for updating a project.
  """
  def update_changeset(struct, params) do
    struct
    |> changeset(params)
  end
end
