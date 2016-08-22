defmodule CodeCorps.Factories do
  # with Ecto
  use ExMachina.Ecto, repo: CodeCorps.Repo

  def user_factory do
    %CodeCorps.User{
      username: sequence(:username, &"user#{&1}"),
      email: sequence(:email, &"email-#{&1}@example.com"),
      password: "password"
    }
  end

  def user_role_factory do
    %CodeCorps.UserRole{
      user: build(:user),
      role: build(:role)
    }
  end

  def role_factory do
    %CodeCorps.Role{
      name: sequence(:name, &"Role #{&1}"),
      ability: sequence(:ability, &"Ability for role #{&1}"),
      kind: sequence(:kind, &"Kind for role #{&1}")
    }
  end

  def organization_factory do
    %CodeCorps.Organization{
      name: sequence(:username, &"Organization #{&1}"),
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

  def project_factory do
    %CodeCorps.Project{
      title: sequence(:title, &"Project #{&1}"),
      slug: sequence(:slug, &"project_#{&1}")
    }
  end

  def category_factory do
    %CodeCorps.Category{
      name: sequence(:name, &"Category #{&1}"),
      slug: sequence(:slug, &"category_#{&1}"),
      description: sequence(:description, &"A description for category #{&1}"),
    }
  end

  def project_category_factory do
    %CodeCorps.ProjectCategory{
      project: build(:project),
      category: build(:category)
    }
  end

  def project_skill_factory do
    %CodeCorps.ProjectSkill{
      project: build(:project),
      skill: build(:skill)
    }
  end

  def post_factory do
    %CodeCorps.Post{
      title: "Test post",
      post_type: "issue",
      markdown: "A test post",
      status: "open",
      project: build(:project),
      user: build(:user)
    }
  end

  def skill_factory do
    %CodeCorps.Skill{
      title: sequence(:name, &"Skill #{&1}"),
      description: sequence(:description, &"A description for skill #{&1}"),
    }
  end

  def comment_factory do
    %CodeCorps.Comment{
      body: "I love elixir!",
      markdown: "I love elixir!",
      post: build(:post)
    }
  end
end
