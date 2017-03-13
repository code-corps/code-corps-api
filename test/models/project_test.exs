defmodule CodeCorps.ProjectTest do
  use CodeCorps.ModelCase

  alias CodeCorps.Project

  describe "changeset" do
    @valid_attrs %{title: "A title"}
    @invalid_attrs %{}

    test "with valid attributes" do
      changeset = Project.changeset(%Project{}, @valid_attrs)
      assert changeset.valid?
    end

    test "with invalid attributes" do
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

  describe "create_changeset" do
    @valid_attrs %{title: "A title", organization_id: 1, owner_id: 1}
    @invalid_attrs %{}

    test "with valid attributes" do
      changeset = Project.create_changeset(%Project{}, @valid_attrs)
      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = Project.create_changeset(%Project{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "accepts setting of organization_id" do
      changeset = Project.create_changeset(%Project{}, %{organization_id: 1})
      assert {:ok, 1} == changeset |> fetch_change(:organization_id)
    end

    test "associates the ordered default task lists to the project" do
      organization = insert(:organization)
      user = insert(:user)
      changeset = Project.create_changeset(
        %Project{},
        %{organization_id: organization.id, title: "Title", owner_id: user.id}
      )

      {_, project} = Repo.insert(changeset)

      task_list_orders = for task_list <- project.task_lists, do: task_list.order

      assert Enum.all?(task_list_orders), "some of the orders are not set (nil)"
      assert task_list_orders == Enum.sort(task_list_orders), "task lists order does not correspond to their position"
    end

    test "also inserts an owner role project_user record"
  end

  describe "update_changeset" do
    test "rejects setting of organization id" do
      changeset = Project.update_changeset(%Project{}, %{organization_id: 1})
      assert :error == changeset |> fetch_change(:organization_id)
    end

    test "requires :website to be in proper format" do
      project = %Project{}
      attrs = %{website: "bad <> website"}

      changeset = Project.update_changeset(project, attrs)

      assert_error_message(changeset, :website, "has invalid format")
    end

    test "doesn't require :website to be part of the changes" do
      project = %Project{}
      attrs = %{}

      changeset = Project.update_changeset(project, attrs)

      refute Keyword.has_key?(changeset.errors, :website)
    end

    test "prefixes website with 'http://' if there is no prefix" do
      project = %Project{website: "https://first.com"}
      attrs = %{website: "example.com"}

      changeset = Project.update_changeset(project, attrs)

      assert changeset.changes.website == "http://example.com"
    end

    test "doesn't make a change to the url when there is no param for it" do
      project = %Project{website: "https://first.com"}
      attrs = %{}

      changeset = Project.update_changeset(project, attrs)

      refute Map.has_key?(changeset.changes, :website)
    end
  end
end
