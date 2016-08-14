defmodule CodeCorps.TestHelpers do
  alias CodeCorps.Repo
  alias CodeCorps.Skill
  alias CodeCorps.User
  alias CodeCorps.Organization
  alias CodeCorps.Project

  def insert_skill(attrs \\ %{}) do
    %Skill{}
    |> Skill.changeset(attrs)
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

  def insert_organization(attrs \\ %{}) do
    changes = Map.merge(attrs, %{
      name: "Test organization",
      description: "Test description"
    })

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
end
