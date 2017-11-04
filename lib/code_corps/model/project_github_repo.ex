defmodule CodeCorps.ProjectGithubRepo do
  @moduledoc """
  Represents a link between a Project and a GithubRepo.
  """

  use CodeCorps.Model

  @type t :: %__MODULE__{}

  schema "project_github_repos" do
    belongs_to :github_repo, CodeCorps.GithubRepo
    belongs_to :project, CodeCorps.Project

    timestamps(type: :utc_datetime)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:github_repo_id, :project_id])
    |> validate_required([:github_repo_id, :project_id])
    |> assoc_constraint(:github_repo)
    |> assoc_constraint(:project)
  end
end
