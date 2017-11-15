defmodule CodeCorps.Repo.Migrations.MigrateProjectGithubReposToGithubRepo do
  use Ecto.Migration

  import Ecto.Query

  alias CodeCorps.Repo

  def up do
    project_github_repos = from(
      pgr in "project_github_repos",
      left_join:
        gr in "github_repos",
        on: gr.id == pgr.github_repo_id,
      select: {pgr.project_id, pgr.sync_state, gr.id, gr.sync_state, pgr.id}
    ) |> Repo.all()

    project_github_repos
    |> Enum.each(fn {project_id, project_repo_state, repo_id, repo_state, project_repo_id} ->

      sync_state = transform_sync_state(project_repo_state, repo_state)

      from(
        gr in "github_repos",
        where: [id: ^repo_id],
        inner_join:
          pgr in "project_github_repos",
          on: gr.id == pgr.github_repo_id,
          where: pgr.id == ^project_repo_id,
        update: [set: [project_id: ^project_id, sync_state: ^sync_state]]
      ) |> Repo.update_all([])
    end)
  end

  defp transform_sync_state("unsynced", repo_state), do: repo_state
  defp transform_sync_state("syncing_github_repo", repo_state), do: repo_state
  defp transform_sync_state("errored_syncing_github_repo", repo_state), do: repo_state
  defp transform_sync_state(project_repo_state, _repo_state), do: project_repo_state

  def down do
    # unsupported
  end
end
