defmodule CodeCorps.TestHelpers do
  alias CodeCorps.Comment
  alias CodeCorps.Organization
  alias CodeCorps.Post
  alias CodeCorps.Project
  alias CodeCorps.Repo
  alias CodeCorps.Role
  alias CodeCorps.UserRole
  alias CodeCorps.RoleSkill
  alias CodeCorps.Skill
  alias CodeCorps.User
  alias CodeCorps.UserSkill

  def insert_skill(attrs \\ %{}) do
    changes = Map.merge(%{
      title: "A skill"
    }, attrs)

    %Skill{}
    |> Skill.changeset(changes)
    |> Repo.insert!()
  end

  def insert_user(attrs \\ %{}) do
    changes = Map.merge(%{
      email: "test#{Base.encode16(:crypto.strong_rand_bytes(8))}@user.com",
      username: "user#{Base.encode16(:crypto.strong_rand_bytes(8))}",
      password: "password",
    }, attrs)

    %User{}
    |> User.registration_changeset(changes)
    |> Repo.insert!()
  end

  def insert_role(attrs \\ %{}) do
    changes = Map.merge(%{
      name: "Backend Developer",
      ability: "Backend Development",
      kind: "technology"
    }, attrs)

    %Role{}
    |> Role.changeset(changes)
    |> Repo.insert!()
  end

  def insert_organization(attrs \\ %{}) do
    changes = Map.merge(%{
      name: "Test organization",
      description: "Test description"
    }, attrs)

    %Organization{}
    |> Organization.create_changeset(changes)
    |> Repo.insert!
  end

  def insert_project(attrs \\ %{}) do
    changes = Map.merge(%{
      title: "Default test project #{Base.encode16(:crypto.strong_rand_bytes(8))}",
    }, attrs)

    %Project{}
    |> Project.changeset(changes)
    |> Repo.insert!
  end

  def insert_user_role(attrs \\ %{}) do
    %UserRole{}
    |> UserRole.changeset(attrs)
    |> Repo.insert!
  end

  def insert_user_skill(attrs \\ %{}) do
    %UserSkill{}
    |> UserSkill.changeset(attrs)
    |> Repo.insert!
  end

  def insert_role_skill(attrs \\ %{}) do
    %RoleSkill{}
    |> RoleSkill.changeset(attrs)
    |> Repo.insert!
  end

  def insert_post(attrs \\ %{}) do
    changes = Map.merge(%{
      markdown: "some content",
      post_type: "issue",
      title: "Default test project",
    }, attrs)

    %Post{}
    |> Post.create_changeset(changes)
    |> Repo.insert!
  end

  def insert_comment(attrs \\ %{}) do
    changes = Map.merge(%{
      markdown: "some content",
    }, attrs)

    %Comment{}
    |> Comment.create_changeset(changes)
    |> Repo.insert!
  end
end
