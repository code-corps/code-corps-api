defmodule CodeCorps.Project.Query do
  @moduledoc ~S"""
  Contains queries for retrieving projects
  """
  alias CodeCorps.{
    Helpers.Query,
    Project,
    SluggedRoute,
    Repo
  }

  @doc ~S"""
  Returns a list of `Project` records based on the provided filter.

  If the filter contains a `slug` key, returns all projects for the specified
  `Organization.`

  If the filter does not contain a `slug` key, filters by optional params.
  """
  @spec list(map) :: list(Project.t)
  def list(%{"slug" => slug}) do
    SluggedRoute
    |> Repo.get_by(slug: slug |> String.downcase)
    |> Repo.preload([organization: :projects])
    |> Map.get(:organization)
    |> Map.get(:projects)
  end
  def list(%{} = params) do
    Project
    |> Query.optional_filters(params, ~w(approved)a)
    |> Repo.all()
  end

  @doc ~S"""
  Finds and returns a single `Project` record based on a map of parameters.

  If the map contains a `project_slug` key, retrieves record by `slug`.

  If the map contains an `id`, retrieves by id.
  """
  @spec find(map) :: Project.t | nil
  def find(%{"project_slug" => slug}) do
    Project |> Repo.get_by(slug: slug |> String.downcase)
  end
  def find(%{"id" => id}) do
    Project |> Repo.get(id)
  end
end
