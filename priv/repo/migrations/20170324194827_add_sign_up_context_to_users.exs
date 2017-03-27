defmodule CodeCorps.Repo.Migrations.AddSignUpContextToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :sign_up_context, :string, default: "default"
    end
  end
end
