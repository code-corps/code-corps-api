defmodule CodeCorps.Repo.Migrations.ChangeManagedToTypeOnStripeConnectAccount do
  use Ecto.Migration

  import Ecto.Query

  alias CodeCorps.Repo

  def up do
    alter table(:stripe_connect_accounts) do
      add :type, :string, null: false, default: "custom"
    end

    flush()

    from(
      a in "stripe_connect_accounts",
      where: [managed: false],
      update: [set: [type: "standard"]]
    ) |> Repo.update_all([])

    from(
      a in "stripe_connect_accounts",
      where: [managed: true],
      update: [set: [type: "custom"]]
    ) |> Repo.update_all([])

    flush()

    alter table(:stripe_connect_accounts) do
      remove :managed
    end
  end

  def down do
    alter table(:stripe_connect_accounts) do
      add :managed, :boolean, default: true, null: false
    end

    flush()

    from(
      a in "stripe_connect_accounts",
      where: [type: "standard"],
      update: [set: [managed: false]]
    ) |> Repo.update_all([])

    from(
      a in "stripe_connect_accounts",
      where: [type: "express"],
      update: [set: [managed: true]]
    ) |> Repo.update_all([])

    from(
      a in "stripe_connect_accounts",
      where: [type: "custom"],
      update: [set: [managed: true]]
    ) |> Repo.update_all([])

    flush()

    alter table(:stripe_connect_accounts) do
      remove :type
    end
  end
end
