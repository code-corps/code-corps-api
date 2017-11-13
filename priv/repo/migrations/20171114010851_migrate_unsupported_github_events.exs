defmodule CodeCorps.Repo.Migrations.MigrateUnsupportedGithubEvents do
  use Ecto.Migration

  import Ecto.Query

  alias CodeCorps.Repo

  def up do
    from(
      ge in "github_events",
      where: [failure_reason: "not_fully_implemented"],
      or_where: [failure_reason: "not_yet_implemented"],
      or_where: [failure_reason: "unexpected_action"],
      update: [set: [failure_reason: nil, status: "unsupported"]]
    ) |> Repo.update_all([])
  end

  def down do
    # no-op
  end
end
