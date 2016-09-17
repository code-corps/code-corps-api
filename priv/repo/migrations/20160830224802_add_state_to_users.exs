defmodule CodeCorps.Repo.Migrations.AddStateToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :state, :string, default: "signed_up"
    end
  end
  
end
