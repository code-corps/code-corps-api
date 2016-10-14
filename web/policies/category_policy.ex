defmodule CodeCorps.Category.Policy do
  alias CodeCorps.User

  def can?(user, :create, _record), do: create?(user)
  def can?(user, :update, _record), do: update?(user)

  def create?(%User{admin: true}), do: true
  def create?(%User{admin: false}), do: false

  def update?(%User{admin: true}), do: true
  def update?(%User{admin: false}), do: false
end
