defmodule CodeCorps.GitHub.User do
  @moduledoc """
  Used to perform user actions on the github API
  Also defines a GitHub.User struct
  """
  defstruct [:avatar_url, :email, :id, :login]

  @type t :: %__MODULE__{}

  alias CodeCorps.GitHub

  @single_endpoint "user"

  def new() do

  end

  def me(access_token, opts \\ []) do
    case GitHub.Request.retrieve(@single_endpoint, opts ++ [access_token: access_token]) do
      {:ok, %{"error" => error}} ->
        {:error, error}
      {:ok, %{"avatar_url" => avatar_url, "email" => email, "id" => id, "login" => login}} ->
        {:ok, %__MODULE__{avatar_url: avatar_url, email: email, id: id, login: login}}
    end
  end
end
