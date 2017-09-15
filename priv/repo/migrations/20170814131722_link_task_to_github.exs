defmodule CodeCorps.Repo.Migrations.LinkTaskToGithub do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :github_repo_id, references(:github_repos)
    end

    rename table(:tasks), :github_id, to: :github_issue_number
  end
end
