defmodule CodeCorps.Policy.Preview do
  alias CodeCorps.User

  @spec create?(User.t, map) :: boolean
  def create?(%User{} = user, %{"user_id" => author_id}), do: user.id == author_id
  def create?(%User{}, %{}), do: false
end
