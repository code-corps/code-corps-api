defmodule CodeCorps.Web.UserCategoryPolicy do
  alias CodeCorps.Web.UserCategory
  alias CodeCorps.Web.User
  alias Ecto.Changeset

  def create?(%User{admin: true}, %Changeset{}), do: true
  def create?(%User{id: id}, %Changeset{changes: %{user_id: user_id}}), do: id == user_id
  def create?(%User{}, %Changeset{}), do: false

  def delete?(%User{admin: true}, %UserCategory{}), do: true
  def delete?(%User{id: id}, %UserCategory{user_id: user_id}), do: id == user_id
  def delete?(%User{}, %UserCategory{}), do: false
end
