defmodule CodeCorps.Repo.Migrations.AddGithubAppInstallationOriginField do
  @moduledoc """
  Adds an origin field to the GithubAppInstallation

  The value of this field can be "codecorps" or "github"
  """
  use Ecto.Migration

  def change do
    alter table(:github_app_installations) do
      add :origin, :string, null: false, default: "codecorps"
    end
  end
end
