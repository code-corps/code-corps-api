defmodule CodeCorps.GitHub.User do
  @moduledoc """
  Used to perform user actions on the github API
  """

  alias CodeCorps.{Accounts, GitHub, User}
  alias Ecto.{Changeset}


  @single_endpoint "user"

  @doc """
  POSTs `code` and `state` to GitHub to receive an OAuth token,
  then associates the given user with that OAuth token.

  Also associates any orphaned `GithubAppInstallation` records matching their
  `sender_github_id` field with the user's `github_id`

  Also associates any existing tasks and comments to the newly connected user,
  based on the user's `github_id`

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
    Accounts.update_from_github_oauth(user, user_payload, access_token)
  end

  @doc ~S"""
  Requests the currently authenticated user payload from github
  """
  @spec me(String.t, Keyword.t) :: {:ok, map} | {:error, GitHub.api_error_struct}
  def me(access_token, opts \\ []) do
    case GitHub.Request.retrieve(@single_endpoint, opts ++ [access_token: access_token]) do
      {:ok, response} -> {:ok, response}
      {:error, error} -> {:error, error}
    end
  end
end
