defmodule CodeCorps.Web.PreviewPolicy do
  alias CodeCorps.Web.User
  alias Ecto.Changeset

  def create?(%User{} = user, %Changeset{changes: %{user_id: author_id}}), do: user.id == author_id
  def create?(%User{}, %Changeset{}), do: false
end
