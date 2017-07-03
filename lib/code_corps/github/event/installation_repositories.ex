defmodule CodeCorps.GitHub.Event.InstallationRepositories do
  @moduledoc """
  In charge of dealing with "InstallationRepositories" GitHub Webhook events
  """

  alias CodeCorps.{
    GithubAppInstallation,
    GithubEvent,
    GithubRepo,
    GitHub.Event,
    Repo
  }

  alias Ecto.Changeset

  @doc """
  Handles an "InstallationRepositories" GitHub Webhook event. The event could be
  of subtype "added" or "removed" and is handled differently based on that.

  `InstallationRepositories::added` will
    - find `GithubAppInstallation`
      - marks event as errored if not found
      - marks event as errored if payload does not have keys it needs, meaning
        there's something wrong with our code and we need to updated
    - find or create `GithubRepo` records affected

  `InstallationRepositories::removed` will
    - find `GithubAppInstallation`
      - marks event as errored if not found
      - marks event as errored if payload does not have keys it needs, meaning
        there's something wrong with our code and we need to updated
    - find `GithubRepo` records affected and delete them
      - if there is no `GithubRepo` to delete, it just skips it
      - `ProjectGithubRepo` are deleted automatically, since they are set to
        `on_delete: :delete_all`
  """
  @spec handle(GithubEvent.t, map) :: {:ok, GithubEvent.t}
  def handle(%GithubEvent{action: action} = event, payload) do
    event
    |> Event.start_processing()
    |> do_handle(action, payload)
    |> Event.stop_processing(event)
  end

  @typep outcome :: {:ok, [GithubRepo.t]} |
                    {:error, :no_installation} |
                    {:error, :unexpected_action_or_payload} |
                    {:error, :unexpected_installation_payload} |
                    {:error, :unexpected_repo_payload}

  @spec do_handle({:ok, GithubEvent.t}, String.t, map) :: outcome
  defp do_handle({:ok, %GithubEvent{}}, "added", %{"installation" => installation_attrs, "repositories_added" => repositories_attr_list}) do
    case installation_attrs |> find_installation() do
      nil -> {:error, :no_installation}
      :unexpected_installation_payload -> {:error, :unexpected_installation_payload}
      %GithubAppInstallation{} = installation ->
        case repositories_attr_list |> Enum.all?(&valid?/1) do
          true -> find_or_create_all(installation, repositories_attr_list)
          false -> {:error, :unexpected_repo_payload}
        end
    end
  end
  defp do_handle({:ok, %GithubEvent{}}, "removed", %{"installation" => installation_attrs, "repositories_removed" => repositories_attr_list}) do
    case installation_attrs |> find_installation() do
      nil -> {:error, :no_installation}
      :unexpected_installation_payload -> {:error, :unexpected_installation_payload}
      %GithubAppInstallation{} = installation ->
        case repositories_attr_list |> Enum.all?(&valid?/1) do
          true -> delete_all(installation, repositories_attr_list)
          false -> {:error, :unexpected_repo_payload}
        end
    end
  end
  defp do_handle({:ok, %GithubEvent{}}, _action, _payload), do: {:error, :unexpected_action_or_payload}

  @spec find_installation(any) :: GithubAppInstallation.t | nil | :unexpected_installation_payload
  defp find_installation(%{"id" => github_id}), do: GithubAppInstallation |> Repo.get_by(github_id: github_id)
  defp find_installation(_payload), do: :unexpected_installation_payload

  # should return true if the payload is a map and has the expected keys
  @spec valid?(any) :: boolean
  defp valid?(%{"id" => _, "name" => _}), do: true
  defp valid?(_), do: false

  @spec find_or_create_all(GithubAppInstallation.t, list(map)) :: {:ok, list(GithubRepo.t)}
  defp find_or_create_all(%GithubAppInstallation{} = installation, repositories_attr_list) when is_list(repositories_attr_list) do
    repositories_attr_list
    |> Enum.map(&find_or_create(installation, &1))
    |> aggregate()
  end

  @spec find_or_create(GithubAppInstallation.t, map) :: {:ok, GithubRepo.t}
  defp find_or_create(%GithubAppInstallation{} = installation, %{"id" => github_id, "name" => name} = attrs) do
    case find_repo(installation, attrs) do
      nil ->
        %GithubRepo{}
        |> Changeset.change(%{github_id: github_id, name: name})
        |> Changeset.put_assoc(:github_app_installation, installation)
        |> Repo.insert()
      %GithubRepo{} = github_repo ->
        {:ok, github_repo}
    end
  end

  @spec delete_all(GithubAppInstallation.t, list(map)) :: {:ok, [GithubRepo.t]}
  defp delete_all(%GithubAppInstallation{} = installation, repositories_attr_list) when is_list(repositories_attr_list) do
    repositories_attr_list
    |> Enum.map(&find_repo(installation, &1))
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&Repo.delete/1)
    |> aggregate()
  end

  @spec find_repo(GithubAppInstallation.t, map) :: GithubRepo.t | nil
  defp find_repo(%GithubAppInstallation{id: installation_id}, %{"id" => github_id}) do
    GithubRepo
    |> Repo.get_by(github_app_installation_id: installation_id, github_id: github_id)
  end

  # [{:ok, repo_1}, {:ok, repo_2}, {:ok, repo_3}] -> {:ok, [repo_1, repo_2, repo_3]}
  @spec aggregate(list({:ok, GithubRepo.t})) :: {:ok, list(GithubRepo.t)}
  defp aggregate(results) do
    repositories =
      results
      |> Enum.map(fn {:ok, %GithubRepo{} = github_repo} -> github_repo end)

    {:ok, repositories}
  end
end
