defmodule CodeCorps.UserSkillPolicy do
  alias CodeCorps.UserSkill
  alias CodeCorps.User

  def create?(%User{admin: true}, %Ecto.Changeset{}), do: true
  def create?(%User{} = user, %Ecto.Changeset{} = changeset) do
    user.id == changeset |> Ecto.Changeset.get_change(:user_id)
  end

  def delete?(%User{admin: true}, %UserSkill{}), do: true
  def delete?(%User{} = user, %UserSkill{} = user_skill), do: user.id == user_skill.user_id
end
