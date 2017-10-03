defmodule CodeCorps.Repo.Migrations.AddCreatedAtAndModifiedAtToComments do
  use Ecto.Migration

  def change do
    alter table(:comments) do
      add :created_at, :utc_datetime
      add :modified_at, :utc_datetime
      add :created_from, :string, default: "code_corps"
      add :modified_from, :string, default: "code_corps"
    end
  end
end
