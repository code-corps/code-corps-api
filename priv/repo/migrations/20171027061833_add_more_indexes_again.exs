defmodule CodeCorps.Repo.Migrations.AddMoreIndexesAgain do
  use Ecto.Migration

  def change do
    create index(:auth_token, [:value])
    create index(:github_events, [:github_delivery_id], unique: true)
    create index(:github_events, [:status])
    create index(:stripe_external_accounts, [:id_from_stripe], unique: true)
    create index(:stripe_file_upload, [:id_from_stripe], unique: true)
    create index(:tasks, [:number])
    create index(:tasks, [:order])
    create index(:task_lists, [:inbox])
    create index(:task_lists, [:order])
  end
end
