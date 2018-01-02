defmodule CodeCorps.Policy.UserInvite do
  alias CodeCorps.{Policy.Helpers, User}

  def create?(%User{} = user, %{"project_id" => _} = params) do
    user_role =
      params
      |> Helpers.get_project()
      |> Helpers.get_membership(user)
      |> Helpers.get_role()

    new_role = Map.get(params, "role")
    do_create?(user_role, new_role)
  end
  def create?(%User{}, %{}), do: true

  defp do_create?("admin", "pending"), do: true
  defp do_create?("admin", "contributor"), do: true
  defp do_create?("owner", "pending"), do: true
  defp do_create?("owner", "contributor"), do: true
  defp do_create?("owner", "admin"), do: true
  defp do_create?(_, _), do: false
end
