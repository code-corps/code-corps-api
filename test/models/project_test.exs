defmodule CodeCorps.ProjectTest do
  use CodeCorps.ModelCase

  alias CodeCorps.Project

  @valid_attrs %{title: "A title"}
  @invalid_attrs %{}

  test "changeset with valid attributes is valid" do
    changeset = Project.changeset(%Project{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes is invalid and has errors" do
    changeset = Project.changeset(%Project{}, @invalid_attrs)
    refute changeset.valid?

    assert changeset.errors[:title] == {"can't be blank", []}
  end

  test "changeset with long_description_markdown renders long_description_body" do
    changeset = Project.changeset(%Project{}, @valid_attrs |> Map.merge(%{long_description_markdown: "Something"}))
    assert changeset |> fetch_change(:long_description_body) == { :ok, "<p>Something</p>\n" }
  end

  test "changeset without long_description_markdown doesn't render long_description_body" do
    changeset = Project.changeset(%Project{}, @valid_attrs)
    assert changeset |> fetch_change(:long_description_body) == :error
  end

  test "create changeset with valid attributes" do
    changeset = Project.create_changeset(%Project{}, @valid_attrs)
    assert changeset.valid?
    assert changeset.changes.slug == "a-title"
  end

  test "create changeset with invalid attributes" do
    changeset = Project.create_changeset(%Project{}, @invalid_attrs)
    refute changeset.valid?
  end

  @tag :requires_env
  test "uploads base64icon data to aws" do
    # 1x1 black pixel gif
    icon_data = "data:image/gif;base64,R0lGODlhAQABAIAAAAUEBAAAACwAAAAAAQABAAACAkQBADs="
    project = insert_project
    attrs = %{base64_icon_data: icon_data, title: "Test"}

    changeset = Project.changeset(project, attrs)

    assert changeset.valid?
    [_, file_type] = changeset.changes.icon.file_name |> String.split(".")
    assert file_type == "gif"
  end
end
