defmodule CodeCorps.GitHub.Event.Issues.UserLinker do
  @moduledoc ~S"""
  In charge of finding a user to link with a Task when processing an Issues
  webhook.
  """

  alias CodeCorps.{
    Accounts,
    Repo,
    User
  }

  @doc ~S"""
  Finds or creates a user using information contained in an Issues webhook
  payload
  """
  @spec find_or_create_user(map) :: {:ok, User.t}
  def find_or_create_user(%{"issue" => %{"user" => user_attrs}}) do
    case user_attrs |> find_user() do
      nil -> user_attrs |> Accounts.create_from_github
      %User{} = user -> {:ok, user}
    end
  end

  @spec find_user(map) :: User.t | nil
  defp find_user(%{"id" => github_id}) do
    User |> Repo.get_by(github_id: github_id)
  end
end
