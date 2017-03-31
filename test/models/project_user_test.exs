defmodule CodeCorps.Web.ProjectUserTest do
  use CodeCorps.ModelCase

  alias CodeCorps.{ProjectUser, Repo}

  describe "update_changeset role validation" do
    test "includes pending" do
      attrs = %{role: "pending"}
      changeset = ProjectUser.update_changeset(%ProjectUser{}, attrs)
      assert changeset.valid?
    end

    test "includes contributor" do
      attrs = %{role: "contributor"}
      changeset = ProjectUser.update_changeset(%ProjectUser{}, attrs)
      assert changeset.valid?
    end

    test "includes admin" do
      attrs = %{role: "admin"}
      changeset = ProjectUser.update_changeset(%ProjectUser{}, attrs)
      assert changeset.valid?
    end

    test "includes owner" do
      attrs = %{role: "owner"}
      changeset = ProjectUser.update_changeset(%ProjectUser{}, attrs)
      assert changeset.valid?
    end

    test "does not include invalid values" do
      attrs = %{role: "invalid"}
      changeset = ProjectUser.update_changeset(%ProjectUser{}, attrs)
      refute changeset.valid?
    end
  end

  describe "create_owner_changeset/2" do
    @attributes ~w(project_id user_id role)

    test "casts #{@attributes}, with role cast to 'owner'" do
      attrs = %{foo: "bar", project_id: 1, user_id: 2}
      changeset = ProjectUser.create_owner_changeset(%ProjectUser{}, attrs)
      assert changeset.changes == %{project_id: 1, user_id: 2, role: "owner"}
    end

    test "ensures user record exists" do
      project = insert(:project)
      attrs = %{project_id: project.id, user_id: -1}
      changeset = ProjectUser.create_owner_changeset(%ProjectUser{}, attrs)

      {:error, invalid_changeset} = changeset |> Repo.insert
      refute invalid_changeset.valid?

      assert assoc_constraint_triggered?(invalid_changeset, :user)
    end

    test "ensures project record exists" do
      user = insert(:user)
      attrs = %{project_id: -1, user_id: user.id}
      changeset = ProjectUser.create_owner_changeset(%ProjectUser{}, attrs)

      {:error, invalid_changeset} = changeset |> Repo.insert
      refute invalid_changeset.valid?

      assert assoc_constraint_triggered?(invalid_changeset, :project)
    end
  end

  describe "create_changeset/2" do
    @attributes ~w(project_id user_id role)

    test "casts #{@attributes}, with role cast to 'pending'" do
      attrs = %{foo: "bar", project_id: 1, user_id: 2}
      changeset = ProjectUser.create_changeset(%ProjectUser{}, attrs)
      assert changeset.changes == %{project_id: 1, user_id: 2, role: "pending"}
    end

    test "ensures user record exists" do
      project = insert(:project)
      attrs = %{project_id: project.id, user_id: -1}
      changeset = ProjectUser.create_changeset(%ProjectUser{}, attrs)

      {:error, invalid_changeset} = changeset |> Repo.insert
      refute invalid_changeset.valid?

      assert assoc_constraint_triggered?(invalid_changeset, :user)
    end

    test "ensures project record exists" do
      user = insert(:user)
      attrs = %{project_id: -1, user_id: user.id}
      changeset = ProjectUser.create_changeset(%ProjectUser{}, attrs)

      {:error, invalid_changeset} = changeset |> Repo.insert
      refute invalid_changeset.valid?

      assert assoc_constraint_triggered?(invalid_changeset, :project)
    end
  end
end
