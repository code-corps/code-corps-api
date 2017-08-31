defmodule CodeCorps.Policy.Category do
  alias CodeCorps.{ User }
  
  @spec create?(User.t) :: boolean
  def create?(%User{admin: true}), do: true
  def create?(%User{}), do: false

  @spec update?(User.t) :: boolean
  def update?(%User{admin: true}), do: true
  def update?(%User{}), do: false
end
