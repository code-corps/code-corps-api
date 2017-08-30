defmodule CodeCorps.Policy.Category do
  def create?(%{admin: true}), do: true
  def create?(%{admin: false}), do: false

  def update?(%{admin: true}), do: true
  def update?(%{admin: false}), do: false
end
