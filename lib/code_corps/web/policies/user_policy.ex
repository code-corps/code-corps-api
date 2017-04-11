defmodule CodeCorps.Web.UserPolicy do
  alias CodeCorps.Web.User

  def update?(%User{} = user, %User{} = current_user), do: user.id == current_user.id
end
