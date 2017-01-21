defmodule CodeCorps.Repo.Migrations.AddIgnoredReasonToStripeEvents do
  use Ecto.Migration

  def change do
    alter table(:stripe_events) do
      add :ignored_reason, :string
    end
  end
end
