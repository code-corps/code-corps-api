defmodule CodeCorps.Accounts.UserInvites do
  alias CodeCorps.{Repo, UserInvite}
  alias Ecto.Changeset

  @spec create_invite(map) :: {:ok, UserInvite.t} | {:error, Changeset.t}
  def create_invite(%{} = params) do
    %UserInvite{}
    |> Changeset.cast(params, [:email, :name, :role, :inviter_id, :project_id])
    |> Changeset.validate_required([:email, :inviter_id])
    |> Changeset.validate_inclusion(:role, ~w(contributor admin owner))
    |> Changeset.assoc_constraint(:inviter)
    |> Changeset.assoc_constraint(:project)
    |> Repo.insert
  end
end
