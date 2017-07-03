defmodule CodeCorps.Repo.Migrations.AddGithubAppInstallationSenderGithubId do
  @moduledoc """
  Migration to add a `sender_github_id` field to a `GithubAppInstallation`.
  This is required when creating an unmatced installation, to associate it with
  a github user at a later time.
  """
  use Ecto.Migration

  def change do
    alter table(:github_app_installations) do
      add :sender_github_id, :integer
    end
  end
end
