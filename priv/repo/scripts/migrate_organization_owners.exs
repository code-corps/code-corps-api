defmodule CodeCorps.Repo.Scripts.MigrateOrganizationOwners do
  require Logger

  import Ecto.Query

  alias CodeCorps.{OrganizationMembership, Repo}

  def run do
    OrganizationMembership
    |> where([m], m.role == "owner")
    |> Repo.all()
    |> Repo.preload([:organization])
    |> Enum.map(&migrate_owner/1)
    |> aggregate_results
    |> log
  end

  defp migrate_owner(%OrganizationMembership{member_id: user_id, organization: organization}) do
    organization |> Ecto.Changeset.cast(%{owner_id: user_id}, [:owner_id]) |> Repo.update()
  end

  defp aggregate_results(results) do
    passing_count = Enum.count(results, fn({status, _}) -> status == :ok end)
    error_count = Enum.count(results, fn({status, _}) -> status == :error end)
    {passing_count, error_count}
  end

  defp log({passing_count, error_count}) do
    Logger.info("#{passing_count} owners migrated, #{error_count} errors.")
  end
end

CodeCorps.Repo.Scripts.MigrateOrganizationOwners.run()
