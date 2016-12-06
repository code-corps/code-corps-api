defmodule CodeCorps.Factories do
  use CodeCorps.JsonPayloadStrategy
  # with Ecto
  use ExMachina.Ecto, repo: CodeCorps.Repo

  def category_factory do
    %CodeCorps.Category{
      name: sequence(:name, &"Category #{&1}"),
      slug: sequence(:slug, &"category-#{&1}"),
      description: sequence(:description, &"A description for category #{&1}"),
    }
  end

  def comment_factory do
    %CodeCorps.Comment{
      body: "I love elixir!",
      markdown: "I love elixir!",
      task: build(:task),
      user: build(:user)
    }
  end

  def donation_goal_factory do
    %CodeCorps.DonationGoal{
      amount: 100,
      description: sequence(:description, &"A description for a donation goal #{&1}"),
      project: build(:project)
    }
  end

  def organization_factory do
    %CodeCorps.Organization{
      name: sequence(:username, &"Organization #{&1}"),
      slug: sequence(:slug, &"organization-#{&1}"),
      description: sequence(:email, &"Description of organization #{&1}"),
    }
  end

  def organization_membership_factory do
    %CodeCorps.OrganizationMembership{
      member: build(:user),
      organization: build(:organization),
      role: "contributor"
    }
  end

  def task_factory do
    %CodeCorps.Task{
      title: "Test task",
      task_type: "issue",
      markdown: "A test task",
      status: "open",
      state: "published",
      project: build(:project),
      user: build(:user)
    }
  end

  def project_factory do
    %CodeCorps.Project{
      title: sequence(:title, &"Project #{&1}"),
      slug: sequence(:slug, &"project-#{&1}"),
      organization: build(:organization)
    }
  end

  def project_category_factory do
    %CodeCorps.ProjectCategory{
      project: build(:project),
      category: build(:category)
    }
  end

  def role_factory do
    %CodeCorps.Role{
      name: sequence(:name, &"Role #{&1}"),
      ability: sequence(:ability, &"Ability for role #{&1}"),
      kind: sequence(:kind, &"Kind for role #{&1}")
    }
  end

  def role_skill_factory do
    %CodeCorps.RoleSkill{
      role: build(:role),
      skill: build(:skill)
    }
  end

  def set_password(user, password) do
    hashed_password = Comeonin.Bcrypt.hashpwsalt(password)
    %{user | encrypted_password: hashed_password}
  end

  def skill_factory do
    %CodeCorps.Skill{
      description: sequence(:description, &"A description for category #{&1}"),
      title: sequence(:title, &"Category #{&1}"),
    }
  end

  def slugged_route_factory do
    %CodeCorps.SluggedRoute{
      slug: sequence(:slug, &"slug-#{&1}")
    }
  end

  def stripe_connect_account_factory do
    %CodeCorps.StripeConnectAccount{
      id_from_stripe: sequence(:id_from_stripe, &"stripe_id_#{&1}"),
      organization: build(:organization)
    }
  end

  def stripe_connect_card_factory do
    %CodeCorps.StripeConnectCard{
      id_from_stripe: sequence(:id_from_stripe, &"stripe_id_#{&1}"),
      stripe_connect_account: build(:stripe_connect_account),
      stripe_platform_card: build(:stripe_platform_card)
    }
  end

  def stripe_connect_customer_factory do
    %CodeCorps.StripeConnectCustomer{
      id_from_stripe: sequence(:id_from_stripe, &"stripe_id_#{&1}"),
      stripe_connect_account: build(:stripe_connect_account)
    }
  end

  def stripe_connect_plan_factory do
    %CodeCorps.StripeConnectPlan{
      id_from_stripe: sequence(:id_from_stripe, &"stripe_id_#{&1}"),
      project: build(:project)
    }
  end

  def stripe_connect_subscription_factory do
    stripe_connect_plan = build(:stripe_connect_plan)
    %CodeCorps.StripeConnectSubscription{
      id_from_stripe: sequence(:id_from_stripe, &"stripe_id_#{&1}"),
      plan_id_from_stripe: stripe_connect_plan.id_from_stripe,
      stripe_connect_plan: stripe_connect_plan,
      user: build(:user)
    }
  end

  def stripe_platform_customer_factory do
    %CodeCorps.StripePlatformCustomer{
      created: Timex.now,
      email: sequence(:email, &"email_#{&1}@mail.com"),
      id_from_stripe: sequence(:id_from_stripe, &"stripe_id_#{&1}"),
      user: build(:user)
    }
  end

  def stripe_platform_card_factory do
    %CodeCorps.StripePlatformCard{
      id_from_stripe: sequence(:id_from_stripe, &"card_testDataMiscCaps#{&1}"),
      user: build(:user)
    }
  end

  def user_factory do
    %CodeCorps.User{
      username: sequence(:username, &"user#{&1}"),
      email: sequence(:email, &"email-#{&1}@example.com")
    }
  end

  def user_category_factory do
    %CodeCorps.UserCategory{
      user: build(:user),
      category: build(:category)
    }
  end

  def user_role_factory do
    %CodeCorps.UserRole{
      user: build(:user),
      role: build(:role)
    }
  end

  def user_skill_factory do
    %CodeCorps.UserSkill{
      user: build(:user),
      skill: build(:skill)
    }
  end

  def project_skill_factory do
    %CodeCorps.ProjectSkill{
      project: build(:project),
      skill: build(:skill)
    }
  end

  def preview_factory do
    %CodeCorps.Preview{
      body: "Bar",
      markdown: "Bar",
      user: build(:user)
    }
  end
end
