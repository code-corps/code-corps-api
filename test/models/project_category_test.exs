defmodule CodeCorps.ProjectCategoryTest do
  use CodeCorps.ModelCase

  alias CodeCorps.ProjectCategory

  test "valid_changeset_is_valid" do
    project_id = insert(:project).id
    category_id = insert(:category).id

    changeset = ProjectCategory.create_changeset(%ProjectCategory{}, %{project_id: project_id, category_id: category_id})
    assert changeset.valid?
  end

  test "changeset requires project_id" do
    category_id = insert(:category).id

    changeset = ProjectCategory.create_changeset(%ProjectCategory{}, %{category_id: category_id})

    refute changeset.valid?
    changeset |> assert_validation_triggered(:project_id, :required)
  end

  test "changeset requires category_id" do
    project_id = insert(:project).id

    changeset = ProjectCategory.create_changeset(%ProjectCategory{}, %{project_id: project_id})

    refute changeset.valid?
    changeset |> assert_validation_triggered(:category_id, :required)
  end

  test "changeset requires id of actual project" do
    project_id = -1
    category_id = insert(:category).id

    { result, changeset } =
      ProjectCategory.create_changeset(%ProjectCategory{}, %{project_id: project_id, category_id: category_id})
      |> Repo.insert

    assert result == :error
    refute changeset.valid?
    changeset |> assert_error_message(:project, "does not exist")
  end

  test "changeset requires id of actual category" do
    project_id = insert(:project).id
    category_id = -1

    { result, changeset } =
      ProjectCategory.create_changeset(%ProjectCategory{}, %{project_id: project_id, category_id: category_id})
      |> Repo.insert

    assert result == :error
    refute changeset.valid?
    changeset |> assert_error_message(:category, "does not exist")
  end
end
