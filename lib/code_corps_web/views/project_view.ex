defmodule CodeCorpsWeb.ProjectView do
  @moduledoc false
  alias CodeCorps.StripeService.Validators.ProjectCanEnableDonations
  alias CodeCorps.Presenters.ImagePresenter

  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [
  	:approved, :can_activate_donations, :cloudinary_public_id,
    :description, :donations_active, :icon_thumb_url,
    :icon_large_url, :inserted_at, :long_description_body,
    :long_description_markdown, :should_link_externally, :slug, :title,
    :total_monthly_donated, :updated_at, :website
  ]

  has_one :organization, serializer: CodeCorpsWeb.OrganizationView, include: true
  has_one :stripe_connect_plan, serializer: CodeCorpsWeb.StripeConnectPlanView

  has_many :donation_goals, serializer: CodeCorpsWeb.DonationGoalView, identifiers: :always
  has_many :project_categories, serializer: CodeCorpsWeb.ProjectCategoryView, include: true
  has_many :project_github_repos, serializer: CodeCorpsWeb.ProjectGithubRepoView, identifiers: :always
  has_many :project_skills, serializer: CodeCorpsWeb.ProjectSkillView, include: true
  has_many :project_users, serializer: CodeCorpsWeb.ProjectUserView, include: true
  has_many :tasks, serializer: CodeCorpsWeb.TaskView, identifiers: :always
  has_many :task_lists, serializer: CodeCorpsWeb.TaskListView, identifiers: :always

  def can_activate_donations(project, _conn) do
    case ProjectCanEnableDonations.validate(project) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  def donations_active(project, _conn) do
    Enum.any?(project.donation_goals) && project.stripe_connect_plan != nil
  end

  def icon_large_url(project, _conn), do: ImagePresenter.large(project)

  def icon_thumb_url(project, _conn), do: ImagePresenter.thumbnail(project)
end
