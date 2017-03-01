defmodule CodeCorps.Analytics.SegmentEventNameBuilder do
  @moduledoc """
  Used for building friendly event names for use in Segment tracking
  """

  @spec build(atom, struct) :: String.t
  def build(action, record), do: get_event_name(action, record)

  @actions_without_properties [:updated_profile, :signed_in, :signed_out, :signed_up]

  defp get_event_name(action, _) when action in @actions_without_properties do
    friendly_action_name(action)
  end
  defp get_event_name(:update, %CodeCorps.DonationGoal{}) do
    "Updated Donation Goal"
  end
  defp get_event_name(:create, %CodeCorps.OrganizationMembership{}) do
    "Requested Organization Membership"
  end
  defp get_event_name(:update, %CodeCorps.OrganizationMembership{}) do
    "Approved Organization Membership"
  end
  defp get_event_name(:create, %CodeCorps.ProjectUser{}) do
    "Requested Project Membership"
  end
  defp get_event_name(:update, %CodeCorps.ProjectUser{}) do
    "Approved Project Membership"
  end
  defp get_event_name(:payment_succeeded, %CodeCorps.StripeInvoice{}) do
    "Processed Subscription Payment"
  end
  defp get_event_name(:create, %CodeCorps.User{}), do: "Signed Up"
  defp get_event_name(:update, %CodeCorps.User{}), do: "Updated Profile"
  defp get_event_name(:create, %CodeCorps.UserCategory{}), do: "Added User Category"
  defp get_event_name(:create, %CodeCorps.UserSkill{}), do: "Added User Skill"
  defp get_event_name(:create, %CodeCorps.UserRole{}), do: "Added User Role"
  defp get_event_name(:create, %{token: _, user_id: _}), do: "Signed In"
  defp get_event_name(action, model) do
    [friendly_action_name(action), friendly_model_name(model)] |> Enum.join(" ")
  end

  defp friendly_action_name(:create), do: "Created"
  defp friendly_action_name(:delete), do: "Removed"
  defp friendly_action_name(:update), do: "Edited"
  defp friendly_action_name(action) do
    action
    |> Atom.to_string
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp friendly_model_name(model) do
    model.__struct__
    |> Module.split
    |> List.last
    |> Macro.underscore
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end
end
