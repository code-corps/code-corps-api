defmodule CodeCorps.GitHub.OAuth do
  @moduledoc """
  Used to perform GitHub OAuth requests and actions.
  """
  alias CodeCorps.{GitHub, Repo, User}

  @doc """
  POSTs `code` and `state` to GitHub to receive an OAuth token,
  then associates the given user with that OAuth token.

  Returns one of the following:

  - `{:ok, %CodeCorps.User{}}`
  - `{:error, %Ecto.Changeset{}}`
  - `{:error, "some_github_error"}`
  """
  @spec connect(User.t, String.t, String.t) :: {:ok, User.t} | {:error, String.t}
  def connect(%User{} = user, code, state) do
    with {:ok, %{"access_token" => github_auth_token}} <- GitHub.user_access_token_request(code, state),
         {:ok, %GitHub.User{avatar_url: avatar_url, email: email, id: id, login: login}} <- github_auth_token |> GitHub.User.me()
    do
       user |> associate(%{github_auth_token: github_auth_token, github_avatar_url: avatar_url, github_email: email, github_id: id, github_username: login})
     else
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Associates user with the GitHub OAuth token.

  Returns one of the following:

  - {:ok, %CodeCorps.User{}}
  - {:error, %Ecto.Changeset{}}
  """
  @spec associate(User.t, map) :: {:ok, User.t} | {:error, Ecto.Changeset.t}
  def associate(user, params) do
    user
    |> User.github_association_changeset(params)
    |> Repo.update()
  end
end
