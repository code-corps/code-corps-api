defmodule CodeCorps.Factories do
  # with Ecto
  use ExMachina.Ecto, repo: CodeCorps.Repo

  def category_factory do
    %CodeCorps.Category{
      name: sequence(:name, &"Category #{&1}"),
      slug: sequence(:slug, &"category_#{&1}"),
      description: sequence(:description, &"A description for category #{&1}"),
    }
  end

  def comment_factory do
    %CodeCorps.Comment{
      body: "I love elixir!",
      markdown: "I love elixir!",
      post: build(:post)
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

  def project_factory do
    %CodeCorps.Project{
      title: sequence(:title, &"Project #{&1}"),
      slug: sequence(:slug, &"project_#{&1}")
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
end
