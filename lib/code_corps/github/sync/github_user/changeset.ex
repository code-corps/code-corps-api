defmodule CodeCorps.GitHub.Sync.GithubUser.Changeset do
  @moduledoc ~S"""
  In charge of changesets for actions on `CodeCorps.GithubUser` records.
  """

  alias CodeCorps.GithubUser
  alias Ecto.Changeset

  @doc ~S"""
  Builds a changeset for creating or updating a `CodeCorps.GithubUser` record.
  """
  @spec changeset(GithubUser.t(), map) :: Changeset.t()
  def changeset(%GithubUser{} = struct, %{} = attrs) do
    struct
    |> Changeset.cast(attrs, [:avatar_url, :email, :github_id, :username, :type])
    |> Changeset.validate_required([:avatar_url, :github_id, :username, :type])
  end
end
