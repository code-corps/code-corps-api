defmodule CodeCorps.Repo.Migrations.AddGithubAccountFieldsToGithubAppInstallation do
  @moduledoc """
  These fields are used to hold account information, to be displayed in the
  client UI.
  """
  use Ecto.Migration

  def change do
    alter table(:github_app_installations) do
      add :github_account_avatar_url, :string
      add :github_account_id, :integer
      add :github_account_login, :string
      add :github_account_type, :string
    end
  end
end
