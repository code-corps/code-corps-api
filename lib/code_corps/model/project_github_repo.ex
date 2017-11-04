defmodule CodeCorps.ProjectGithubRepo do
  @moduledoc """
  Represents a link between a Project and a GithubRepo.
  """

  use CodeCorps.Model

  @type t :: %__MODULE__{}

  schema "project_github_repos" do
    field :sync_state, :string, default: "unsynced"

    belongs_to :github_repo, CodeCorps.GithubRepo
    belongs_to :project, CodeCorps.Project

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def create_changeset(struct, params) do
    struct
    |> changeset(params)
    |> assoc_constraint(:github_repo)
    |> assoc_constraint(:project)
  end

  defp changeset(struct, params) do
    struct
    |> cast(params, [:github_repo_id, :project_id, :sync_state])
    |> validate_required([:github_repo_id, :project_id])
  end

  def update_sync_changeset(struct, params) do
    struct
    |> changeset(params)
    |> validate_inclusion(:sync_state, sync_states())
  end

  def sync_states do
    ~w{
      unsynced
      syncing_github_repo errored_syncing_github_repo
      syncing_users errored_syncing_users
      syncing_tasks errored_syncing_tasks
      syncing_comments errored_syncing_comments
      synced
    }
  end
end
