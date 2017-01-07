defmodule CodeCorps.ProjectTest do
  use CodeCorps.ModelCase

  alias CodeCorps.Project

  @valid_attrs %{title: "A title"}
  @invalid_attrs %{}

  describe "changeset/2" do
    test "with valid attributes is valid" do
      changeset = Project.changeset(%Project{}, @valid_attrs)
      assert changeset.valid?
    end

    test "with invalid attributes is invalid and has errors" do
      changeset = Project.changeset(%Project{}, @invalid_attrs)
      refute changeset.valid?

      assert_error_message(changeset, :title, "can't be blank")
    end

    test "with long_description_markdown renders long_description_body" do
      changeset = Project.changeset(%Project{}, @valid_attrs |> Map.merge(%{long_description_markdown: "Something"}))
      assert changeset |> fetch_change(:long_description_body) == {:ok, "<p>Something</p>\n"}
    end

    test "without long_description_markdown doesn't render long_description_body" do
      changeset = Project.changeset(%Project{}, @valid_attrs)
      assert changeset |> fetch_change(:long_description_body) == :error
    end

    @tag :requires_env
    test "uploads base64icon data to aws" do
      # 1x1 black pixel gif
      icon_data = "data:image/gif;base64,R0lGODlhAQABAIAAAAUEBAAAACwAAAAAAQABAAACAkQBADs="
      project = insert(:project)
      attrs = %{base64_icon_data: icon_data, title: "Test"}

      changeset = Project.changeset(project, attrs)

      assert changeset.valid?
      [_, file_type] = changeset.changes.icon.file_name |> String.split(".")
      assert file_type == "gif"
    end

    test "generates slug from title" do
      changeset = Project.changeset(%Project{}, @valid_attrs)
      assert changeset |> get_change(:slug) == "a-title"
    end

    test "validates slug is unique" do
      project = insert(:project, slug: "used-slug")
      changeset = Project.changeset(%Project{organization_id: project.organization_id}, %{title: "Used Slug"})

      {_, changeset} = Repo.insert(changeset)
      assert_error_message(changeset, :slug, "has already been taken")
    end
  end

  describe "create_changeset/2" do
    test "accepts setting of organization_id" do
      changeset = Project.create_changeset(%Project{}, %{organization_id: 1})
      assert {:ok, 1} == changeset |> fetch_change(:organization_id)
    end

    test "associates the default task lists to the project" do
      organization = insert(:organization)
      changeset = Project.create_changeset(%Project{}, %{organization_id: organization.id, title: "Title"})

      {_, project} = Repo.insert(changeset)

      orders = for task_list <- project.task_lists do; task_list.order; end

      assert orders == [1, 2, 3, 4]
    end
  end

  describe "update_changeset/2" do
    test "rejects setting of organization id" do
      changeset = Project.update_changeset(%Project{}, %{organization_id: 1})
      assert :error == changeset |> fetch_change(:organization_id)
    end
  end
end
