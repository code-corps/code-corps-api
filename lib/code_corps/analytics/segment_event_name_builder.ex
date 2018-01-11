defmodule CodeCorps.Analytics.SegmentEventNameBuilder do
  @moduledoc """
  Used for building friendly event names for use in Segment tracking
  """

  alias CodeCorps.Analytics.SegmentTrackingSupport

  @spec build(String.t, atom, struct) :: String.t
  def build(id, action, record), do: get_event_name(id, action, record)

  @actions_without_properties [:updated_profile, :signed_in, :signed_out, :signed_up]

  defp get_event_name(_, action, _) when action in @actions_without_properties do
    friendly_action_name(action)
  end
  defp get_event_name(_, :update, %CodeCorps.DonationGoal{}) do
    "Updated Donation Goal"
  end
  defp get_event_name(id, :create, %CodeCorps.ProjectUser{}) do
    if SegmentTrackingSupport.project_id?(id) do
      "Membership Requested (Project)"
    else
      "Requested Membership (User)"
    end
  end
  defp get_event_name(id, :update, %CodeCorps.ProjectUser{}) do
    if SegmentTrackingSupport.project_id?(id) do
      "Approved Membership (Project)"
    else
      "Membership Approved (User)"
    end
  end
  defp get_event_name(_, :payment_succeeded, %CodeCorps.StripeInvoice{}) do
    "Processed Subscription Payment"
  end
  defp get_event_name(_, :create, %CodeCorps.User{}), do: "Signed Up"
  defp get_event_name(_, :update, %CodeCorps.User{}), do: "Updated Profile"
  defp get_event_name(_, :create, %CodeCorps.UserCategory{}), do: "Added User Category"
  defp get_event_name(_, :create, %CodeCorps.UserSkill{}), do: "Added User Skill"
  defp get_event_name(_, :create, %CodeCorps.UserRole{}), do: "Added User Role"
  defp get_event_name(_, :create, %{token: _, user_id: _}), do: "Signed In"
  defp get_event_name(_, action, model) do
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
