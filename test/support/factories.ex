defmodule CodeCorps.Factories do
  @moduledoc false

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
      created_at: DateTime.utc_now,
      markdown: "I love elixir!",
      modified_at: DateTime.utc_now,
      task: build(:task),
      user: build(:user)
    }
  end

  def conversation_factory do
    %CodeCorps.Conversation{
      status: "open",
      read_at: nil,
      message: build(:message),
      user: build(:user)
    }
  end

  def conversation_part_factory do
    %CodeCorps.ConversationPart{
      body: sequence(:body, &"Reply to conversation #{&1}"),
      read_at: nil,
      author: build(:user),
      conversation: build(:conversation)
    }
  end

  def donation_goal_factory do
    %CodeCorps.DonationGoal{
      amount: 100,
      description: sequence(:description, &"A description for a donation goal #{&1}"),
      project: build(:project)
    }
  end

  def github_app_installation_factory do
    %CodeCorps.GithubAppInstallation{
      github_account_id: sequence(:github_account_login, &(&1)),
      github_account_avatar_url: sequence(:github_account_avatar_url, &"http://test-#{&1}.com"),
      github_account_login: sequence(:github_account_login, &"owner_#{&1}"),
      github_id: sequence(:github_id, &(&1)),
      github_account_type: "User",
      project: build(:project),
      user: build(:user)
    }
  end

  def github_comment_factory do
    %CodeCorps.GithubComment{
      body: sequence(:body, &"I love elixir with GithubComment #{&1}"),
      github_created_at: DateTime.utc_now,
      github_id: sequence(:id, (fn number -> number end)),
      github_updated_at: DateTime.utc_now,
      github_issue: build(:github_issue)
    }
  end

  def github_event_factory do
    %CodeCorps.GithubEvent{}
  end

  def github_issue_factory do
    %CodeCorps.GithubIssue{
      body: "I love elixir!",
      github_created_at: DateTime.utc_now,
      github_id: sequence(:id, (fn number -> number end)),
      github_updated_at: DateTime.utc_now,
      locked: false,
      number: sequence(:id, (fn number -> number end)),
      state: "open",
      title: "I love Elixir!",
      github_repo: build(:github_repo)
    }
  end

  def github_issue_assignee_factory do
    %CodeCorps.GithubIssueAssignee{
      github_issue: build(:github_issue),
      github_user: build(:github_user)
    }
  end

  def github_pull_request_factory do
    %CodeCorps.GithubPullRequest{
      body: "Here's a change!",
      github_created_at: DateTime.utc_now,
      github_id: sequence(:id, (fn number -> number end)),
      github_updated_at: DateTime.utc_now,
      locked: false,
      merged: false,
      number: sequence(:id, (fn number -> number end)),
      state: "open",
      title: "Here's a change!",
      github_repo: build(:github_repo)
    }
  end

  def github_repo_factory do
    %CodeCorps.GithubRepo{
      github_account_login: sequence(:github_account_login, &"owner_#{&1}"),
      github_app_installation: build(:github_app_installation),
      github_id: sequence(:github_id, &(&1)),
      name: sequence(:name, &"repo_#{&1}"),
      project: build(:project)
    }
  end

  def github_user_factory do
    %CodeCorps.GithubUser{
      github_id: sequence(:id, (fn number -> number end))
    }
  end

  def message_factory do
    %CodeCorps.Message{
      body: sequence(:body, &"Subject #{&1}"),
      initiated_by: "admin",
      subject: sequence(:subject, &"Subject #{&1}"),
      author: build(:user),
      project: build(:project)
    }
  end

  def organization_factory do
    %CodeCorps.Organization{
      name: sequence(:username, &"Organization #{&1}"),
      owner: build(:user),
      slug: sequence(:slug, &"organization-#{&1}"),
      description: sequence(:email, &"Description of organization #{&1}"),
    }
  end

  def organization_invite_factory do
    %CodeCorps.OrganizationInvite{
      code: sequence(:code, &"n43crhiqR-#{&1}"),
      email: sequence(:email, &"email_#{&1}@mail.com"),
      organization_name: sequence(:organization_name, &"organization-#{&1}")
    }
  end

  def task_factory do
    %CodeCorps.Task{
      created_at: DateTime.utc_now,
      markdown: "A test task",
      modified_at: DateTime.utc_now,
      status: "open",
      title: "Test task",
      project: build(:project),
      user: build(:user),
      task_list: build(:task_list)
    }
  end

  def task_list_factory do
    %CodeCorps.TaskList{
      name: "Test task list",
      position: 1,
      project: build(:project)
    }
  end

  def task_skill_factory do
    %CodeCorps.TaskSkill{
      skill: build(:skill),
      task: build(:task)
    }
  end

  def organization_github_app_installation_factory do
    %CodeCorps.OrganizationGithubAppInstallation{
      github_app_installation: build(:github_app_installation),
      organization: build(:organization)
    }
  end

  def project_factory do
    %CodeCorps.Project{
      approved: true,
      long_description_markdown: sequence(:long_description_markdown, &"Description #{&1}"), # once approved, this MUST be set
      slug: sequence(:slug, &"project-#{&1}"),
      title: sequence(:title, &"Project #{&1}"),
      website: sequence(:website, &"http://test-#{&1}.com"),

      organization: build(:organization)
    }
  end

  def project_user_factory do
    %CodeCorps.ProjectUser{
      project: build(:project),
      user: build(:user),
      role: "contributor"
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

  @spec set_password(CodeCorps.User.t, String.t) :: CodeCorps.User.t
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

  def stripe_connect_charge_factory do
    %CodeCorps.StripeConnectCharge{
      amount: 1000,
      currency: "usd",
      id_from_stripe: sequence(:id_from_stripe, &"stripe_id_#{&1}"),
      stripe_connect_account: build(:stripe_connect_account),
      stripe_connect_customer: build(:stripe_connect_customer),
      user: build(:user)
    }
  end

  def stripe_connect_customer_factory do
    %CodeCorps.StripeConnectCustomer{
      id_from_stripe: sequence(:id_from_stripe, &"stripe_id_#{&1}"),
      stripe_connect_account: build(:stripe_connect_account),
      stripe_platform_customer: build(:stripe_platform_customer),
      user: build(:user)
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

  def stripe_event_factory do
    %CodeCorps.StripeEvent{
      endpoint: sequence(:endpoint, fn(_) -> Enum.random(~w{ connect platform }) end),
      id_from_stripe: sequence(:id_from_stripe, &"stripe_id_#{&1}"),
      object_id: "cus_123",
      object_type: "customer",
      status: sequence(:status, fn(_) -> Enum.random(~w{ unprocessed processed errored }) end),
      type: "test.type"
    }
  end

  def stripe_external_account_factory do
    %CodeCorps.StripeExternalAccount{
      account_id_from_stripe: sequence(:id_from_stripe, &"stripe_id_#{&1}"),
      id_from_stripe: sequence(:id_from_stripe, &"stripe_id_#{&1}")
    }
  end

  def stripe_file_upload_factory do
    %CodeCorps.StripeFileUpload{
      id_from_stripe: sequence(:id_from_stripe, &"stripe_id_#{&1}"),
    }
  end

  def stripe_invoice_factory do
    %CodeCorps.StripeInvoice{
      id_from_stripe: sequence(:id_from_stripe, &"stripe_id_#{&1}"),
      charge_id_from_stripe: sequence(:id_from_stripe, &"charge_stripe_id_#{&1}"),
      customer_id_from_stripe: sequence(:id_from_stripe, &"customer_stripe_id_#{&1}"),
      subscription_id_from_stripe: sequence(:subscription_id_from_stripe, &"subscription_stripe_id_#{&1}"),
      stripe_connect_subscription: build(:stripe_connect_subscription),
      user: build(:user)
    }
  end

  def stripe_platform_customer_factory do
    %CodeCorps.StripePlatformCustomer{
      created: Timex.now |> Timex.to_unix,
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
      first_name: sequence(:first_name, &"First#{&1}"),
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

  def user_task_factory do
    %CodeCorps.UserTask{
      user: build(:user),
      task: build(:task)
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
