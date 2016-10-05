defmodule CodeCorps.UserSkillPolicy do
  alias CodeCorps.UserSkill
  alias CodeCorps.User
  alias Ecto.Changeset

  def create?(%User{admin: true}, %Changeset{}), do: true
  def create?(%User{id: id}, %Changeset{changes: %{user_id: user_id}}), do: id == user_id
  def create?(%User{}, %Changeset{}), do: false

  def delete?(%User{admin: true}, %UserSkill{}), do: true
  def delete?(%User{id: id}, %UserSkill{user_id: user_id}), do: id == user_id
  def delete?(%User{}, %UserSkill{}), do: false
end
