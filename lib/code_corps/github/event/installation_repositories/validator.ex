defmodule CodeCorps.GitHub.Event.InstallationRepositories.Validator do
  @moduledoc ~S"""
  In charge of validatng a GitHub InstallationRepositories webhook payload.

  [https://developer.github.com/v3/activity/events/types/#installationrepositoriesevent](https://developer.github.com/v3/activity/events/types/#installationrepositoriesevent)
  """

  @doc ~S"""
  Returns `true` if all keys required to properly handle an
  InstallationRepositories webhook are present in the provided payload.
  """
  @spec valid?(map) :: boolean
  def valid?(%{
    "action" => _, "installation" => %{"id" => _},
    "repositories_added" => added, "repositories_removed" => removed})
    when is_list(added) when is_list(removed) do

    (added ++ removed) |> Enum.all?(&repository_valid?/1)
  end
  def valid?(%{
    "action" => _, "installation" => %{"id" => _},
    "repositories_added" => added}) when is_list(added) do

    added |> Enum.all?(&repository_valid?/1)
  end
  def valid?(%{
    "action" => _, "installation" => %{"id" => _},
    "repositories_removed" => removed}) when is_list(removed) do

    removed |> Enum.all?(&repository_valid?/1)
  end
  def valid?(_), do: false

  @spec repository_valid?(any) :: boolean
  defp repository_valid?(%{"id" => _, "name" => _}), do: true
  defp repository_valid?(_), do: false
end
