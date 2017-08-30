defmodule CodeCorps.GitHub.User do
  @moduledoc """
  Used to perform user actions on the github API
  """

  alias CodeCorps.{GitHub, GithubAppInstallation, Repo, User}
  alias CodeCorps.GitHub.Adapters.User, as: UserAdapter
  alias Ecto.{Changeset, Multi}

  import Ecto.Query

  @single_endpoint "user"

  @doc """
  POSTs `code` and `state` to GitHub to receive an OAuth token,
  then associates the given user with that OAuth token.

  Also associates any orphaned `GithubAppInstallation` records matching their
  `sender_github_id` field with the user's `github_id`

  Returns one of the following:

  - `{:ok, %CodeCorps.User{}}`
  - `{:error, %Ecto.Changeset{}}`
  - `{:error, GitHub.api_error_struct}`
  """
  @spec connect(User.t, String.t, String.t) ::
    {:ok, User.t} | {:error, Changeset.t} | {:error, GitHub.api_error_struct}
  def connect(%User{} = user, code, state) do
    with {:ok, %{"access_token" => access_token}} <- GitHub.user_access_token_request(code, state),
         {:ok, %{} = user_payload} <- access_token |> GitHub.User.me()
    do
       user |> do_connect(user_payload, access_token)
    else
      {:error, error} -> {:error, error}
    end
  end

  @spec do_connect(User.t, map, String.t) :: {:ok, User.t} | {:error, Changeset.t}
  defp do_connect(%User{} = user, %{} = user_payload, access_token)
    when is_binary(access_token) do

    changeset =
      user
      |> Changeset.change(user_payload |> UserAdapter.from_github_user)
      |> Changeset.put_change(:github_auth_token, access_token)
      |> Changeset.validate_required([:github_auth_token, :github_avatar_url, :github_id, :github_username])

    multi =
      Multi.new
      |> Multi.update(:user, changeset)
      |> Multi.run(:installations, fn %{user: %User{} = user} -> user |> associate_installations() end)

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

  @doc ~S"""
  Requests the currently authenticated user payload from github
  """
  @spec me(String.t, Keyword.t) :: {:ok, map} | {:error, GitHub.api_error_struct}
  def me(access_token, opts \\ []) do
    case GitHub.Request.retrieve(@single_endpoint, opts ++ [access_token: access_token]) do
      {:ok, %{"error" => error}} -> {:error, error}
      {:ok, %{} = user_payload} -> {:ok, user_payload}
    end
  end
end
