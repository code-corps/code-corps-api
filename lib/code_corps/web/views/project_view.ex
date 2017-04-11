defmodule CodeCorps.Web.ProjectView do
  alias CodeCorps.StripeService.Validators.ProjectCanEnableDonations
  alias CodeCorps.Presenters.ImagePresenter

  use CodeCorps.PreloadHelpers,
    default_preloads: [
      :donation_goals, [organization: :stripe_connect_account],
      :project_categories, :project_skills, :project_users,
      :stripe_connect_plan, :task_lists, :tasks
    ]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [
  	:approved, :can_activate_donations, :cloudinary_public_id,
    :description, :donations_active, :icon_thumb_url,
    :icon_large_url, :inserted_at, :long_description_body,
    :long_description_markdown, :should_link_externally, :slug, :title,
    :total_monthly_donated, :updated_at, :website
  ]

  has_one :organization, serializer: CodeCorps.Web.OrganizationView
  has_one :stripe_connect_plan, serializer: CodeCorps.Web.StripeConnectPlanView

  has_many :donation_goals, serializer: CodeCorps.Web.DonationGoalView, identifiers: :always
  has_many :project_categories, serializer: CodeCorps.Web.ProjectCategoryView, identifiers: :always
  has_many :project_skills, serializer: CodeCorps.Web.ProjectSkillView, identifiers: :always
  has_many :project_users, serializer: CodeCorps.Web.ProjectUserView, identifiers: :always
  has_many :task_lists, serializer: CodeCorps.Web.TaskListView, identifiers: :always
  has_many :tasks, serializer: CodeCorps.Web.TaskView, identifiers: :always

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
