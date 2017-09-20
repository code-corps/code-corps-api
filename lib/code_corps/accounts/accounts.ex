defmodule CodeCorps.Accounts do
  @moduledoc ~S"""
  Main entry-point for managing accounts.

  All actions to acounts should go through here.
  """

  alias CodeCorps.{
    GitHub.Adapters,
    User,
    Repo
  }
  alias Ecto.Changeset

  @doc ~S"""
  Creates a user record using attributes from a GitHub payload.
  """
  @spec create_from_github(map) :: {:ok, User.t} | {:error, Changeset.t}
  def create_from_github(%{} = attrs) do
    %User{}
    |> Changeset.change(attrs |> Adapters.User.from_github_user())
    |> Changeset.put_change(:context, "github")
    |> Changeset.unique_constraint(:email)
    |> Repo.insert
  end
end
