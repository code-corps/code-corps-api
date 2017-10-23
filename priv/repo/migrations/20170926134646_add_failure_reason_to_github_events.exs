defmodule CodeCorps.Repo.Migrations.AddFailureReasonToGithubEvents do
  use Ecto.Migration

  def change do
    alter table(:github_events) do
      add :failure_reason, :string
    end
  end
end
