defmodule CodeCorps.Factories do
  @moduledoc false

  # with Ecto
  use ExMachina.Ecto, repo: CodeCorps.Repo

  def category_factory do
    %CodeCorps.Web.Category{
      name: sequence(:name, &"Category #{&1}"),
      slug: sequence(:slug, &"category-#{&1}"),
      description: sequence(:description, &"A description for category #{&1}"),
    }
  end

  def comment_factory do
    %CodeCorps.Web.Comment{
      body: "I love elixir!",
      markdown: "I love elixir!",
      task: build(:task),
      user: build(:user)
    }
  end

  def donation_goal_factory do
    %CodeCorps.Web.DonationGoal{
      amount: 100,
      description: sequence(:description, &"A description for a donation goal #{&1}"),
      project: build(:project)
    }
  end

  def organization_factory do
    %CodeCorps.Web.Organization{
      name: sequence(:username, &"Organization #{&1}"),
      owner: build(:user),
      slug: sequence(:slug, &"organization-#{&1}"),
      description: sequence(:email, &"Description of organization #{&1}"),
    }
  end

  def task_factory do
    %CodeCorps.Web.Task{
      title: "Test task",
      markdown: "A test task",
      status: "open",
      state: "published",
      project: build(:project),
      user: build(:user),
      task_list: build(:task_list)
    }
  end

  def task_list_factory do
    %CodeCorps.Web.TaskList{
      name: "Test task list",
      position: 1,
      project: build(:project)
    }
  end

  def task_skill_factory do
    %CodeCorps.Web.TaskSkill{
      skill: build(:skill),
      task: build(:task)
    }
  end

  def project_factory do
    %CodeCorps.Web.Project{
      approved: true,
      long_description_markdown: sequence(:long_description_markdown, &"Description #{&1}"), # once approved, this MUST be set
      slug: sequence(:slug, &"project-#{&1}"),
      title: sequence(:title, &"Project #{&1}"),
      website: sequence(:website, &"http://test-#{&1}.com"),

      organization: build(:organization)
    }
  end

  def project_user_factory do
    %CodeCorps.Web.ProjectUser{
      project: build(:project),
      user: build(:user),
      role: "contributor"
    }
  end

  def project_category_factory do
    %CodeCorps.Web.ProjectCategory{
      project: build(:project),
      category: build(:category)
    }
  end

  def role_factory do
    %CodeCorps.Web.Role{
      name: sequence(:name, &"Role #{&1}"),
      ability: sequence(:ability, &"Ability for role #{&1}"),
      kind: sequence(:kind, &"Kind for role #{&1}")
    }
  end

  def role_skill_factory do
    %CodeCorps.Web.RoleSkill{
      role: build(:role),
      skill: build(:skill)
    }
  end

  @spec set_password(CodeCorps.Web.User.t, String.t) :: CodeCorps.Web.User.t
  def set_password(user, password) do
    hashed_password = Comeonin.Bcrypt.hashpwsalt(password)
    %{user | encrypted_password: hashed_password}
  end

  def skill_factory do
    %CodeCorps.Web.Skill{
      description: sequence(:description, &"A description for category #{&1}"),
      title: sequence(:title, &"Category #{&1}"),
    }
  end

  def slugged_route_factory do
    %CodeCorps.Web.SluggedRoute{
      slug: sequence(:slug, &"slug-#{&1}")
    }
  end

  def stripe_connect_account_factory do
    %CodeCorps.Web.StripeConnectAccount{
      id_from_stripe: sequence(:id_from_stripe, &"stripe_id_#{&1}"),
      organization: build(:organization)
    }
  end

  def stripe_connect_card_factory do
    %CodeCorps.Web.StripeConnectCard{
      id_from_stripe: sequence(:id_from_stripe, &"stripe_id_#{&1}"),
      stripe_connect_account: build(:stripe_connect_account),
      stripe_platform_card: build(:stripe_platform_card)
    }
  end

  def stripe_connect_charge_factory do
    %CodeCorps.Web.StripeConnectCharge{
      id_from_stripe: sequence(:id_from_stripe, &"stripe_id_#{&1}"),
      stripe_connect_account: build(:stripe_connect_account),
      stripe_connect_customer: build(:stripe_connect_customer),
      user: build(:user)
    }
  end

  def stripe_connect_customer_factory do
    %CodeCorps.Web.StripeConnectCustomer{
      id_from_stripe: sequence(:id_from_stripe, &"stripe_id_#{&1}"),
      stripe_connect_account: build(:stripe_connect_account),
      stripe_platform_customer: build(:stripe_platform_customer),
      user: build(:user)
    }
  end

  def stripe_connect_plan_factory do
    %CodeCorps.Web.StripeConnectPlan{
      id_from_stripe: sequence(:id_from_stripe, &"stripe_id_#{&1}"),
      project: build(:project)
    }
  end

  def stripe_connect_subscription_factory do
    stripe_connect_plan = build(:stripe_connect_plan)
    %CodeCorps.Web.StripeConnectSubscription{
      id_from_stripe: sequence(:id_from_stripe, &"stripe_id_#{&1}"),
      plan_id_from_stripe: stripe_connect_plan.id_from_stripe,
      stripe_connect_plan: stripe_connect_plan,
      user: build(:user)
    }
  end

  def stripe_event_factory do
    %CodeCorps.Web.StripeEvent{
      endpoint: sequence(:endpoint, fn(_) -> Enum.random(~w{ connect platform }) end),
      id_from_stripe: sequence(:id_from_stripe, &"stripe_id_#{&1}"),
      object_id: "cus_123",
      object_type: "customer",
      status: sequence(:status, fn(_) -> Enum.random(~w{ unprocessed processed errored }) end),
      type: "test.type"
    }
  end

  def stripe_external_account_factory do
    %CodeCorps.Web.StripeExternalAccount{
      account_id_from_stripe: sequence(:id_from_stripe, &"stripe_id_#{&1}"),
      id_from_stripe: sequence(:id_from_stripe, &"stripe_id_#{&1}")
    }
  end

  def stripe_file_upload_factory do
    %CodeCorps.Web.StripeFileUpload{
      id_from_stripe: sequence(:id_from_stripe, &"stripe_id_#{&1}"),
    }
  end

  def stripe_invoice_factory do
    %CodeCorps.Web.StripeInvoice{
      id_from_stripe: sequence(:id_from_stripe, &"stripe_id_#{&1}"),
      charge_id_from_stripe: sequence(:id_from_stripe, &"charge_stripe_id_#{&1}"),
      customer_id_from_stripe: sequence(:id_from_stripe, &"customer_stripe_id_#{&1}"),
      subscription_id_from_stripe: sequence(:subscription_id_from_stripe, &"subscription_stripe_id_#{&1}"),
      stripe_connect_subscription: build(:stripe_connect_subscription),
      user: build(:user)
    }
  end

  def stripe_platform_customer_factory do
    %CodeCorps.Web.StripePlatformCustomer{
      created: Timex.now |> Timex.to_unix,
      email: sequence(:email, &"email_#{&1}@mail.com"),
      id_from_stripe: sequence(:id_from_stripe, &"stripe_id_#{&1}"),
      user: build(:user)
    }
  end

  def stripe_platform_card_factory do
    %CodeCorps.Web.StripePlatformCard{
      id_from_stripe: sequence(:id_from_stripe, &"card_testDataMiscCaps#{&1}"),
      user: build(:user)
    }
  end

  def user_factory do
    %CodeCorps.Web.User{
      first_name: sequence(:first_name, &"First#{&1}"),
      username: sequence(:username, &"user#{&1}"),
      email: sequence(:email, &"email-#{&1}@example.com")
    }
  end

  def user_category_factory do
    %CodeCorps.Web.UserCategory{
      user: build(:user),
      category: build(:category)
    }
  end

  def user_role_factory do
    %CodeCorps.Web.UserRole{
      user: build(:user),
      role: build(:role)
    }
  end

  def user_skill_factory do
    %CodeCorps.Web.UserSkill{
      user: build(:user),
      skill: build(:skill)
    }
  end

  def user_task_factory do
    %CodeCorps.Web.UserTask{
      user: build(:user),
      task: build(:task)
    }
  end

  def project_skill_factory do
    %CodeCorps.Web.ProjectSkill{
      project: build(:project),
      skill: build(:skill)
    }
  end

  def preview_factory do
    %CodeCorps.Web.Preview{
      body: "Bar",
      markdown: "Bar",
      user: build(:user)
    }
  end
end
