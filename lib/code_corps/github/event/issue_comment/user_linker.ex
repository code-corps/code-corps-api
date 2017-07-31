defmodule CodeCorps.GitHub.Event.IssueComment.UserLinker do
  @moduledoc ~S"""
  In charge of finding a user to link with a Task when processing an
  IssueComment webhook.
  """

  alias CodeCorps.{
    Repo,
    User
  }
  alias CodeCorps.GitHub.Adapters.User, as: UserAdapter
  alias Ecto.Changeset

  @doc ~S"""
  Finds or creates a user using information contained in an Issues webhook
  payload
  """
  @spec find_or_create_user(map) :: {:ok, User.t}
  def find_or_create_user(%{"comment" => %{"user" => user_attrs}}) do
    case user_attrs |> find_user() do
      nil -> user_attrs |> create_user()
      %User{} = user -> {:ok, user}
    end
  end

  @spec find_user(map) :: User.t | nil
  defp find_user(%{"id" => github_id}) do
    User |> Repo.get_by(github_id: github_id)
  end

  @spec create_user(map) :: {:ok, User.t}
  defp create_user(%{} = user_attrs) do
    %User{}
    |> Changeset.change(user_attrs |> UserAdapter.from_github_user())
    |> Repo.insert
  end
end
