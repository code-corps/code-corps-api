defmodule CodeCorps.UserCategoryPolicy do
  alias CodeCorps.UserCategory
  alias CodeCorps.User

  def create?(%User{admin: true}, %Ecto.Changeset{}), do: true
  def create?(%User{} = user, %Ecto.Changeset{} = changeset) do
    user.id == changeset |> Ecto.Changeset.get_change(:user_id)
  end

  def delete?(%User{admin: true}, %UserCategory{}), do: true
  def delete?(%User{} = user, %UserCategory{} = user_category), do: user.id == user_category.user_id
end
