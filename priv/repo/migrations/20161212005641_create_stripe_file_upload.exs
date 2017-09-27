defmodule CodeCorps.Repo.Migrations.CreateStripeFileUpload do
  use Ecto.Migration

  def change do
    create table(:stripe_file_upload) do
      add :created, :utc_datetime
      add :id_from_stripe, :string, null: false
      add :purpose, :string
      add :size, :integer
      add :type, :string
      add :url, :string
      add :stripe_connect_account_id, references(:stripe_connect_accounts)
    end
  end
end
