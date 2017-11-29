defmodule CodeCorps.Project do
  @moduledoc """
  Represents a project on Code Corps, e.g. the "Code Corps" project itself.
  """

  use CodeCorps.Model

  import CodeCorps.Helpers.RandomIconColor
  import CodeCorps.Helpers.Slug
  import CodeCorps.Helpers.URL, only: [prefix_url: 2]
  import CodeCorps.Validators.SlugValidator
  import Ecto.Query, only: [where: 3]

  alias CodeCorps.{Category, Repo, Skill, TaskList}
  alias CodeCorps.Services.MarkdownRendererService

  alias Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "projects" do
    field :approved, :boolean
    field :cloudinary_public_id
    field :default_color
    field :description, :string
    field :long_description_body, :string
    field :long_description_markdown, :string
    field :should_link_externally, :boolean, default: false # temporary for linking to projects off Code Corps while in alpha
    field :slug, :string
    field :title, :string
    field :total_monthly_donated, :integer, default: 0
    field :website, :string

    belongs_to :organization, CodeCorps.Organization

    has_one :stripe_connect_plan, CodeCorps.StripeConnectPlan

    has_many :donation_goals, CodeCorps.DonationGoal
    has_many :github_repos, CodeCorps.GithubRepo
    has_many :project_categories, CodeCorps.ProjectCategory
    has_many :project_skills, CodeCorps.ProjectSkill
    has_many :project_users, CodeCorps.ProjectUser
    has_many :task_lists, CodeCorps.TaskList
    has_many :tasks, CodeCorps.Task

    has_many :stripe_connect_subscriptions, through: [:stripe_connect_plan, :stripe_connect_subscriptions]

    many_to_many :categories, CodeCorps.Category, join_through: CodeCorps.ProjectCategory
    many_to_many :skills, CodeCorps.Skill, join_through: CodeCorps.ProjectSkill

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:title, :description, :long_description_markdown, :cloudinary_public_id, :default_color, :website])
    |> prefix_url(:website)
    |> validate_format(:website, CodeCorps.Helpers.URL.valid_format())
    |> validate_required([:title])
    |> generate_slug(:title, :slug)
    |> validate_slug(:slug)
    |> unique_constraint(:slug, name: :index_projects_on_slug)
    |> check_constraint(:long_description_markdown,
                        message: "cannot be deleted once your project is approved",
                        name: "set_long_description_markdown_if_approved")
    |> MarkdownRendererService.render_markdown_to_html(:long_description_markdown, :long_description_body)
  end

  @doc """
  Builds a changeset for creating a project.
  """
  def create_changeset(struct, params) do
    struct
    |> changeset(params)
    |> cast(params, [:organization_id])
    |> validate_required([:cloudinary_public_id, :description])
    |> associate_categories(params)
    |> validate_length(:categories, min: 1)
    |> associate_skills(params)
    |> validate_length(:skills, min: 1)
    |> put_assoc(:task_lists, TaskList.default_task_lists())
    |> put_member_assoc()
    |> generate_icon_color(:default_color)
    |> assoc_constraint(:organization)
  end

  defp associate_categories(changeset, %{"categories_ids" => ids}) when is_list(ids) when length(ids) > 0 do
    categories = ids |> Enum.map(&String.to_integer/1) |> find_categories()
    changeset |> put_assoc(:categories, categories)
  end
  defp associate_categories(changeset, _) do
    changeset |> put_assoc(:categories, [])
  end

  defp find_categories(ids) do
    Category
    |> where([object], object.id in ^ids)
    |> Repo.all()
  end

  defp associate_skills(changeset, %{"skills_ids" => ids}) when is_list(ids) when length(ids) > 0 do
    skills = ids |> Enum.map(&String.to_integer/1) |> find_skills()
    changeset |> put_assoc(:skills, skills)
  end
  defp associate_skills(changeset, _) do
    changeset |> put_assoc(:skills, [])
  end

  defp find_skills(ids) do
    Skill
    |> where([object], object.id in ^ids)
    |> Repo.all()
  end

  @doc """
  Builds a changeset for updating a project.
  """
  def update_changeset(struct, params) do
    struct
    |> changeset(params)
  end

  def update_total_changeset(struct, params) do
    struct
    |> cast(params, [:total_monthly_donated])
  end

  @spec put_member_assoc(Changeset.t) :: Changeset.t
  defp put_member_assoc(changeset) do
    case changeset |> get_change(:organization_id) |> get_organization do
      nil ->
        changeset
      organization ->
        changeset
        |> put_assoc(:project_users, [%{user_id: organization.owner_id, role: "owner"}])
    end
  end

  @spec get_organization(integer | nil) :: CodeCorps.Organization.t | nil
  defp get_organization(nil), do: nil
  defp get_organization(id), do: CodeCorps.Repo.get(CodeCorps.Organization, id)
end
