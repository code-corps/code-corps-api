defmodule CodeCorps.UserRolePolicy do
  alias CodeCorps.UserRole
  alias CodeCorps.User

  def create?(%User{admin: true}, %Ecto.Changeset{}), do: true
  def create?(%User{} = user, %Ecto.Changeset{} = changeset) do
    user.id == changeset |> Ecto.Changeset.get_change(:user_id)
  end

  def delete?(%User{admin: true}, %UserRole{}), do: true
  def delete?(%User{} = user, %UserRole{} = user_role), do: user.id == user_role.user_id
end
