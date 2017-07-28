defmodule CodeCorps.GitHub.User do
  @moduledoc """
  Used to perform user actions on the github API
  """

  alias CodeCorps.{GitHub, Repo, User}
  alias CodeCorps.GitHub.Adapters.User, as: UserAdapter
  alias Ecto.Changeset

  @single_endpoint "user"

  @doc """
  POSTs `code` and `state` to GitHub to receive an OAuth token,
  then associates the given user with that OAuth token.

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
       user
       |> Changeset.change(user_payload |> UserAdapter.from_github_user)
       |> Changeset.put_change(:github_auth_token, access_token)
       |> Changeset.validate_required([:github_auth_token, :github_avatar_url, :github_id, :github_username])
       |> Repo.update
    else
      {:error, error} -> {:error, error}
    end
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
