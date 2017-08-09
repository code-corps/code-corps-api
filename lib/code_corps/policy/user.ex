defmodule CodeCorps.Policy.User do
  alias CodeCorps.User

  def update?(%User{} = user, %User{} = current_user), do: user.id == current_user.id
end
