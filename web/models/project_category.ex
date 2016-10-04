defmodule CodeCorps.ProjectCategory do
  @moduledoc """
  Represents a category of a project.
  """

  use CodeCorps.Web, :model

  schema "project_categories" do
    belongs_to :project, CodeCorps.Project
    belongs_to :category, CodeCorps.Category

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`, for creating a record.
  """
  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:project_id, :category_id])
    |> validate_required([:project_id, :category_id])
    |> assoc_constraint(:project)
    |> assoc_constraint(:category)
  end
end
