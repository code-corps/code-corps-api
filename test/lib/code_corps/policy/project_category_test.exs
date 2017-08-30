defmodule CodeCorps.Policy.ProjectCategoryTest do
  use CodeCorps.PolicyCase

  import CodeCorps.Policy.ProjectCategory, only: [create?: 2, delete?: 2]
  import CodeCorps.ProjectCategory, only: [create_changeset: 2]

  alias CodeCorps.ProjectCategory

  describe "create?" do
    test "returns false when user is not a project member" do
      user = insert(:user)
      project = insert(:project)

      changeset = %ProjectCategory{} |> create_changeset(%{project_id: project.id})
      refute create?(user, changeset)
    end

    test "returns false when user is a pending project member" do
      %{project: project, user: user} = insert(:project_user, role: "pending")

      changeset = %ProjectCategory{} |> create_changeset(%{project_id: project.id})
      refute create?(user, changeset)
    end

    test "returns false when user is a project contributor" do
      %{project: project, user: user} = insert(:project_user, role: "contributor")

      changeset = %ProjectCategory{} |> create_changeset(%{project_id: project.id})
      refute create?(user, changeset)
    end

    test "returns true when user is a project admin" do
      %{project: project, user: user} = insert(:project_user, role: "admin")

      changeset = %ProjectCategory{} |> create_changeset(%{project_id: project.id})
      assert create?(user, changeset)
    end

    test "returns true when user is project owner" do
      %{project: project, user: user} = insert(:project_user, role: "owner")

      changeset = %ProjectCategory{} |> create_changeset(%{project_id: project.id})
      assert create?(user, changeset)
    end
  end

  describe "delete?" do
    test "returns false when user is not a project member" do
      user = insert(:user)
      project = insert(:project)

      record = insert(:project_category, project: project)
      refute delete?(user, record)
    end

    test "returns false when user is a pending project member" do
      %{project: project, user: user} = insert(:project_user, role: "pending")

      record = insert(:project_category, project: project)
      refute delete?(user, record)
    end

    test "returns false when user is a project contributor" do
      %{project: project, user: user} = insert(:project_user, role: "contributor")

      record = insert(:project_category, project: project)
      refute delete?(user, record)
    end

    test "returns true when user is a project admin" do
      %{project: project, user: user} = insert(:project_user, role: "admin")

      record = insert(:project_category, project: project)
      assert delete?(user, record)
    end

    test "returns true when user is project owner" do
      %{project: project, user: user} = insert(:project_user, role: "owner")

      record = insert(:project_category, project: project)
      assert delete?(user, record)
    end
  end
end
