defmodule CodeCorps.GitHub do
  alias CodeCorps.{User, Repo}

  @api Application.get_env(:code_corps, :github_api)

  @doc """
  POSTs `code` to GitHub to receive an OAuth token, then associates the user
  with that OAuth token.

  Accepts a third parameter – a custom API module – for the purposes of
  explicit dependency injection during testing.

  Returns one of the following:

  - `{:ok, %CodeCorps.User{}}`
  - `{:error, %Ecto.Changeset{}}`
  - `{:error, "some_github_error"}`
  """
  @spec connect(User.t, String.t, module) :: {:ok, User.t} | {:error, String.t}
  def connect(%User{} = user, code, api \\ @api) do
    case code |> api.connect do
      {:ok, github_auth_token} -> user |> associate(%{github_auth_token: github_auth_token})
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
