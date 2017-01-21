defmodule CodeCorps.CommentPolicy do
  alias CodeCorps.Comment
  alias CodeCorps.User
  alias Ecto.Changeset

  def create?(%User{} = user, %Changeset{changes: %{user_id: creator_id}}), do: user.id == creator_id
  def create?(%User{}, %Changeset{}), do: false

  def update?(%User{} = user, %Comment{} = comment), do: user.id == comment.user_id
end
