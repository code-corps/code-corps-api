defmodule CodeCorps.Web.ProjectCategory do
  @moduledoc """
  Represents a category of a project.
  """

  use CodeCorps.Web, :model

  @type t :: %__MODULE__{}

  schema "project_categories" do
    belongs_to :project, CodeCorps.Web.Project
    belongs_to :category, CodeCorps.Web.Category

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
