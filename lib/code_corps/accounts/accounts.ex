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
    |> create_from_github_changeset(attrs)
    |> Repo.insert
  end

  @doc ~S"""
  Casts a changeset used for creating a user account from a github user payload
  """
  @spec create_from_github_changeset(struct, map) :: Changeset.t
  def create_from_github_changeset(struct, %{} = params) do
    struct
    |> Changeset.change(params |> Adapters.User.from_github_user())
    |> Changeset.put_change(:context, "github")
    |> Changeset.unique_constraint(:email)
    |> Changeset.validate_inclusion(:type, ["bot", "user"])
  end
end
