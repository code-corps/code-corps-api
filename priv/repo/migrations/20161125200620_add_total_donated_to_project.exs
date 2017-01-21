defmodule CodeCorps.Repo.Migrations.AddTotalDonatedToProject do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :total_monthly_donated, :integer, default: 0
    end
  end
end
