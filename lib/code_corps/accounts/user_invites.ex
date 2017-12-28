defmodule CodeCorps.Accounts.UserInvites do
  alias CodeCorps.{Project, ProjectUser, Repo, User, UserInvite}
  alias Ecto.{Changeset, Multi}

  import Ecto.Query

  @spec create_invite(map) :: {:ok, UserInvite.t} | {:error, Changeset.t}
  def create_invite(%{} = params) do
    %UserInvite{}
    |> Changeset.cast(params, [:email, :name, :role, :inviter_id, :project_id])
    |> Changeset.validate_required([:email, :inviter_id])
    |> Changeset.validate_inclusion(:role, ~w(contributor admin owner))
    |> Changeset.assoc_constraint(:inviter)
    |> Changeset.assoc_constraint(:project)
    |> ensure_email_not_owned_by_member()
    |> Repo.insert
  end

  @spec ensure_email_not_owned_by_member(Changeset.t) :: Changeset.t
  defp ensure_email_not_owned_by_member(%Changeset{} = changeset) do
    email = changeset |> Changeset.get_change(:email)
    project_id = changeset |> Changeset.get_change(:project_id)

    case [email, project_id] do
      [nil, _] -> changeset
      [_, nil] -> changeset
      [email, project_id] ->
        count =
          ProjectUser
          |> where(project_id: ^project_id)
          |> join(:inner, [pu], u in User, pu.user_id == u.id)
          |> where([_pu, u], u.email == ^email)
          |> select([pu, _U], count(pu.id))
          |> Repo.one

        if count > 0 do
          changeset |> Changeset.add_error(:email, "Already associated with a project member")
        else
          changeset
        end
    end
  end

  @spec claim_invite(UserInvite.t) :: {:ok, User.t}
  def claim_invite(%UserInvite{} = user_invite) do
    Multi.new
    |> Multi.run(:user, fn %{} -> user_invite |> claim_user() end)
    |> Multi.run(:project_user, fn %{user: user} -> user |> join_project(user_invite) end)
    |> Multi.run(:user_invite, fn %{user: user} -> user_invite |> associate_invitee(user) end)
    |> Repo.transaction
    |> normalize_success()
  end

  @spec claim_user(UserInvite.t) :: {:ok, User.t}
  defp claim_user(%UserInvite{email: email, name: name}) do
    case User |> Repo.get_by(email: email) do
      %User{} = user -> {:ok, user}
      nil -> %User{} |> Changeset.change(%{email: email, name: name}) |> Repo.insert
    end
  end

  @spec join_project(User.t, UserInvite.t) :: {:ok, ProjectUser.t} | {:error, Changeset.t}
  defp join_project(%User{} = user, %UserInvite{role: role, project: %Project{} = project}) do
    case ProjectUser |> Repo.get_by(user_id: user.id, project_id: project.id) do
      %ProjectUser{} = project_user ->
        {:ok, project_user}
      nil ->
        %ProjectUser{}
        |> Changeset.change(%{role: role})
        |> Changeset.put_assoc(:project, project)
        |> Changeset.put_assoc(:user, user)
        |> Repo.insert
    end
  end
  defp join_project(%User{}, %UserInvite{}), do: {:ok, nil}

  @spec associate_invitee(UserInvite.t, User.t) :: ProjectUser.t
  defp associate_invitee(%UserInvite{invitee: nil} = invite, %User{} = user) do
    invite
    |> Changeset.change(%{})
    |> Changeset.put_assoc(:invitee, user)
    |> Repo.update
  end

  @spec normalize_success(tuple) :: tuple
  defp normalize_success({:ok, %{user: user}}), do: {:ok, user |> Repo.preload(:project_users)}
  defp normalize_success(other_tuple), do: other_tuple
end
