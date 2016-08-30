defmodule CodeCorps.PreviewPolicy do
  alias CodeCorps.User

  def create?(%User{} = _user), do: true
end
