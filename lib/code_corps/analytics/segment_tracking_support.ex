defmodule CodeCorps.Analytics.SegmentTrackingSupport do
  @moduledoc """
  Used to determine what Segment should and should not track
  """

  @doc """
  Determines if Segment should track an action/record combination.
  """
  @spec includes?(atom, struct) :: boolean
  def includes?(:create, %CodeCorps.Comment{}), do: true
  def includes?(:update, %CodeCorps.Comment{}), do: true
  def includes?(:create, %CodeCorps.DonationGoal{}), do: true
  def includes?(:update, %CodeCorps.DonationGoal{}), do: true
  def includes?(:create, %CodeCorps.ProjectUser{}), do: true
  def includes?(:update, %CodeCorps.ProjectUser{}), do: true
  def includes?(:create, %CodeCorps.StripeConnectAccount{}), do: true
  def includes?(:create, %CodeCorps.StripeConnectCharge{}), do: true
  def includes?(:create, %CodeCorps.StripeConnectPlan{}), do: true
  def includes?(:create, %CodeCorps.StripeConnectSubscription{}), do: true
  def includes?(:create, %CodeCorps.StripePlatformCard{}), do: true
  def includes?(:create, %CodeCorps.StripePlatformCustomer{}), do: true
  def includes?(:create, %CodeCorps.User{}), do: true
  def includes?(:update, %CodeCorps.User{}), do: true
  def includes?(:create, %CodeCorps.UserCategory{}), do: true
  def includes?(:delete, %CodeCorps.UserCategory{}), do: true
  def includes?(:create, %CodeCorps.UserRole{}), do: true
  def includes?(:delete, %CodeCorps.UserRole{}), do: true
  def includes?(:create, %CodeCorps.UserSkill{}), do: true
  def includes?(:delete, %CodeCorps.UserSkill{}), do: true
  def includes?(:create, %{token: _, user_id: _}), do: true
  def includes?(_, _), do: false


  @doc """
  Determines whether event id is tracking project.
  """
  @spec project_id?(String.t | integer) :: boolean
  def project_id?(event_id) when is_integer(event_id), do: false
  def project_id?(event_id), do: String.starts_with?(event_id, "project_")
end
