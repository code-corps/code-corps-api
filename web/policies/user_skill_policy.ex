defmodule CodeCorps.UserSkillPolicy do
  alias CodeCorps.UserSkill
  alias CodeCorps.User

  def create?(%User{admin: true}), do: true
  def create?(%User{}), do: false
  # TODO: Need to figure out how to pass in params for create
  # A non-admin user can modify their own skill. This method is right now unreachable
  def create?(%User{} = user, %UserSkill{} = user_skill), do: user.id == user_skill.user_id

  def delete?(%User{admin: true}), do: true
  def delete?(%User{}), do: false
  def delete?(%User{} = user, %UserSkill{} = user_skill), do: user.id == user_skill.user_id
end
