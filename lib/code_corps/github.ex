defmodule CodeCorps.Github do
  alias CodeCorps.{User, Repo}

  @api Application.get_env(:code_corps, :github_api)

  @doc """
  Posts code to github to receive an auth token, associates user with that
  auth token.

  Accepts a third parameter, which is a custom API module, for the purposes of
  explicit dependency injection during testing.

  Returns one of the following:

  - {:ok, %CodeCorps.User{}}
  - {:error, %Ecto.Changeset{}}
  - {:error, "some_github_error"}
  """
  @spec connect(User.t, String.t, module) :: {:ok, User.t} | {:error, String.t}
  def connect(%User{} = user, code, api \\ @api) do
    case code |> api.connect do
      {:ok, github_auth_token} -> user |> associate(%{github_auth_token: github_auth_token})
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Associates user with an auth token

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
