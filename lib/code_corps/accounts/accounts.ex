defmodule CodeCorps.Accounts do
  @moduledoc ~S"""
  Main entry-point for managing accounts.

  All actions to accounts should go through here.
  """

  alias CodeCorps.{
    Accounts.Changesets,
    Comment,
    GitHub.Adapters,
    GithubAppInstallation,
    User,
    Repo,
    Task
  }
  alias Ecto.{Changeset, Multi}

  import Ecto.Query

  @doc ~S"""
  Creates a user record using attributes from a GitHub payload.
  """
  @spec create_from_github(map) :: {:ok, User.t} | {:error, Changeset.t}
  def create_from_github(%{} = attrs) do
    %User{}
    |> Changesets.create_from_github_changeset(attrs)
    |> Repo.insert
  end

  @doc ~S"""
  Updates a user record using attributes from a GitHub payload along with the
  access token.
  """
  @spec update_from_github_oauth(User.t, map, String.t) :: {:ok, User.t} | {:error, Changeset.t}
  def update_from_github_oauth(%User{} = user, %{} = params, access_token) do
    params =
      params
      |> Adapters.User.from_github_user()
      |> Map.put(:github_auth_token, access_token)

    changeset = user |> Changesets.update_from_github_oauth_changeset(params)

    multi =
      Multi.new
      |> Multi.update(:user, changeset)
      |> Multi.run(:installations, fn %{user: %User{} = user} -> user |> associate_installations() end)
      |> Multi.run(:tasks, fn %{user: %User{} = user} -> user |> associate_tasks() end)
      |> Multi.run(:comments, fn %{user: %User{} = user} -> user |> associate_comments() end)

    case Repo.transaction(multi) do
      {:ok, %{user: %User{} = user, installations: installations}} ->
        {:ok, user |> Map.put(:github_app_installations, installations)}
      {:error, :user, %Changeset{} = changeset, _actions_done} ->
        {:error, changeset}
    end
  end

  @spec associate_installations(User.t) :: {:ok, list(GithubAppInstallation.t)}
  defp associate_installations(%User{id: user_id, github_id: github_id}) do
    updates = [set: [user_id: user_id]]
    update_options = [returning: true]

    GithubAppInstallation
    |> where([i], i.sender_github_id == ^github_id)
    |> where([i], is_nil(i.user_id))
    |> Repo.update_all(updates, update_options)
    |> (fn {_count, installations} -> {:ok, installations} end).()
  end

  @spec associate_tasks(User.t) :: {:ok, list(Task.t)}
  defp associate_tasks(%User{id: user_id, github_id: github_id}) do
    updates = [set: [user_id: user_id]]
    update_options = [returning: true]

    existing_user_ids =
      User
      |> where(github_id: ^github_id)
      |> select([u], u.id)
      |> Repo.all

    Task
    |> where([t], t.user_id in ^existing_user_ids)
    |> Repo.update_all(updates, update_options)
    |> (fn {_count, tasks} -> {:ok, tasks} end).()
  end

  @spec associate_comments(User.t) :: {:ok, list(Comment.t)}
  defp associate_comments(%User{id: user_id, github_id: github_id}) do
    updates = [set: [user_id: user_id]]
    update_options = [returning: true]

    existing_user_ids =
      User
      |> where(github_id: ^github_id)
      |> select([u], u.id)
      |> Repo.all

    Comment
    |> where([c], c.user_id in ^existing_user_ids)
    |> Repo.update_all(updates, update_options)
    |> (fn {_count, comments} -> {:ok, comments} end).()
  end
end
