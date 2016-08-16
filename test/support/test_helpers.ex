defmodule CodeCorps.TestHelpers do
  alias CodeCorps.Repo
  alias CodeCorps.Skill
  alias CodeCorps.User
  alias CodeCorps.Role
  alias CodeCorps.Organization
  alias CodeCorps.Project
  alias CodeCorps.UserSkill
  alias CodeCorps.RoleSkill

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
      email: "test@user.com",
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
      title: "Default test project",
      slug: "default_test_project"
    }, attrs)

    %Project{}
    |> Project.changeset(changes)
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

end
