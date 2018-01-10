defmodule CodeCorps.Policy.UserInvite do
  @moduledoc ~S"""
  Handles `CodeCorps.User` authorization of actions on `CodeCorps.UserInvite`
  records.
  """

  alias CodeCorps.{Policy.Helpers, User}

  @doc ~S"""
  Returns true if the specified `CodeCorps.User` is allowed to create a
  `CodeCorps.UserInvite` using the specified attributes.
  """
  @spec create?(User.t(), map) :: boolean
  def create?(
        %User{id: user_id} = user,
        %{"project_id" => _, "inviter_id" => inviter_id} = params
      )
      when user_id == inviter_id do
    user_role =
      params
      |> Helpers.get_project()
      |> Helpers.get_membership(user)
      |> Helpers.get_role()

    new_role = Map.get(params, "role")
    do_create?(user_role, new_role)
  end

  def create?(%User{id: user_id}, %{"inviter_id" => inviter_id})
      when user_id == inviter_id,
      do: true

  def create?(%User{}, %{}), do: false

  @spec do_create?(String.t() | nil, String.t() | nil) :: boolean
  defp do_create?("admin", "pending"), do: true
  defp do_create?("admin", "contributor"), do: true
  defp do_create?("owner", "pending"), do: true
  defp do_create?("owner", "contributor"), do: true
  defp do_create?("owner", "admin"), do: true
  defp do_create?(_, _), do: false
end
