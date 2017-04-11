defmodule CodeCorps.Analytics.SegmentEventNameBuilder do
  @moduledoc """
  Used for building friendly event names for use in Segment tracking
  """

  alias CodeCorps.Web.{
    DonationGoal, ProjectUser, StripeInvoice,
    User, UserCategory, UserRole, UserSkill
  }

  @spec build(atom, struct) :: String.t
  def build(action, record), do: get_event_name(action, record)

  @actions_without_properties [:updated_profile, :signed_in, :signed_out, :signed_up]

  defp get_event_name(action, _) when action in @actions_without_properties do
    friendly_action_name(action)
  end
  defp get_event_name(:update, %DonationGoal{}) do
    "Updated Donation Goal"
  end
  defp get_event_name(:create, %ProjectUser{}) do
    "Requested Project Membership"
  end
  defp get_event_name(:update, %ProjectUser{}) do
    "Approved Project Membership"
  end
  defp get_event_name(:payment_succeeded, %StripeInvoice{}) do
    "Processed Subscription Payment"
  end
  defp get_event_name(:create, %User{}), do: "Signed Up"
  defp get_event_name(:update, %User{}), do: "Updated Profile"
  defp get_event_name(:create, %UserCategory{}), do: "Added User Category"
  defp get_event_name(:create, %UserRole{}), do: "Added User Role"
  defp get_event_name(:create, %UserSkill{}), do: "Added User Skill"
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
