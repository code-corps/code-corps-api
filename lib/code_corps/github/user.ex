defmodule CodeCorps.GitHub.User do
  @moduledoc """
  Used to perform user actions on the github API
  Also defines a GitHub.User struct
  """
  defstruct [:avatar_url, :email, :id, :login]

  @type t :: %__MODULE__{}

  alias CodeCorps.{GitHub, User}

  @single_endpoint "user"

  def new() do

  end

  @doc ~S"""
  Retrieves github information for an auth token belonging to a `CodeCorps.User`

  https://developer.github.com/v3/users/#get-the-authenticated-user
  """
  @spec me(String.t, Keyword.t) :: t | {:error, GitHub.api_error_struct}
  def me(access_token, opts \\ []) do
    case GitHub.Request.retrieve(@single_endpoint, opts ++ [access_token: access_token]) do
      {:error, error} -> {:error, error}
      {:ok, %{"avatar_url" => avatar_url, "email" => email, "id" => id, "login" => login}} ->
        {:ok, %__MODULE__{avatar_url: avatar_url, email: email, id: id, login: login}}
    end
  end

  @doc ~S"""
  Lists installations for a `CodeCorps.User`

  https://developer.github.com/v3/apps/#list-installations-for-user
  """
  @spec installations(User.t, Keyword.t) :: {:ok, list(map)} | {:error, GitHub.api_error_struct}
  def installations(%User{github_auth_token: access_token}, opts \\ []) do
    endpoint = "#{@single_endpoint}/installations"

    case GitHub.Request.retrieve(endpoint, opts ++ [access_token: access_token]) do
      {:error, error} -> {:error, error}
      {:ok, %{"installations" => installations}} -> {:ok, installations}
    end
  end
end
