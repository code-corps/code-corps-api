defmodule CodeCorps.Repo.Migrations.AddVerificationFieldsToStripeConnectAccount do
  use Ecto.Migration

  def change do
    alter table(:stripe_connect_accounts) do
      add :verification_disabled_reason, :string
      add :verification_due_by, :datetime
      add :verification_fields_needed, {:array, :string}
    end
  end
end
