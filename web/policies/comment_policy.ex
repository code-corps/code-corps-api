defmodule CodeCorps.CommentPolicy do
  alias CodeCorps.Comment
  alias CodeCorps.User

  def create?(%User{}), do: true

  def update?(%User{} = user, %Comment{} = comment), do: user.id == comment.user_id
end
