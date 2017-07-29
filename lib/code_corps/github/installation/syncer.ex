defmodule CodeCorps.GitHub.Installation.Syncer do
  @moduledoc """
  Responsible for syncing GitHub installations with local
  `GithubAppInstallation` records
  """

  alias CodeCorps.{
    GithubAppInstallation,
    Repo
  }
  alias CodeCorps.GitHub.Adapters.GithubAppInstallation,
    as: GithubAppInstallationAdapter

  alias Ecto.{Changeset, Multi}

  @doc """
  Takes a list of github installation payloads and syncs them with the database,
  creating new or updating existing `GithubAppInstallation` records.

  This is done in a transaction, so all of them must succeed
  """
  @spec sync(list) :: {:ok, list(GithubAppInstallation.t)} | {:error, atom}
  def sync(installations) when is_list(installations) do
    multi =
      Multi.new
      |> Multi.run(:installations, fn _ -> do_sync(installations) end)

    case Repo.transaction(multi) do
      {:ok, %{installations: installations}} -> {:ok, installations}
      {:error, step, _, _} -> {:error, step}
    end
  end

  @spec do_sync(list) :: {:ok, list(GithubAppInstallation.t)}
  defp do_sync(installations) when is_list(installations) do
    installations
    |> Enum.map(&GithubAppInstallationAdapter.from_installation/1)
    |> Enum.map(&pair_with_record/1)
    |> Enum.map(&create_changeset/1)
    |> Enum.map(&commit/1)
    |> Enum.map(&Tuple.to_list/1) # {:ok, record} -> [:ok, record]
    |> Enum.map(&List.last/1) # [:ok, record] -> record
    |> (fn records -> {:ok, records} end).()
  end

  @spec pair_with_record(map) :: {GithubAppInstallation.t, map}
  defp pair_with_record(%{github_id: github_id} = attrs) do
    case GithubAppInstallation |> Repo.get_by(github_id: github_id) do
      %GithubAppInstallation{} = record -> {record, attrs}
      nil -> {%GithubAppInstallation{}, attrs}
    end
  end

  @spec create_changeset({GithubAppInstallation.t, map}) :: Changeset.t
  defp create_changeset({%GithubAppInstallation{} = record, %{} = attrs}) do
    record |> Changeset.change(attrs)
  end

  @spec commit(Changeset.t) :: {:ok, GithubAppInstallation.t}
  defp commit(%Changeset{data: %GithubAppInstallation{id: nil}} = changeset) do
    changeset |> Repo.insert
  end
  defp commit(%Changeset{} = changeset), do: changeset |> Repo.update
end
