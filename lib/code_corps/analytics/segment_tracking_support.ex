defmodule CodeCorps.Analytics.SegmentTrackingSupport do
  @moduledoc """
  Used to determine what Segment should and should not track
  """

  @doc """
  Determines if Segment should track an action/record combination.
  """
  @spec includes?(atom, struct) :: boolean
  def includes?(:create, %CodeCorps.Web.Comment{}), do: true
  def includes?(:update, %CodeCorps.Web.Comment{}), do: true
  def includes?(:create, %CodeCorps.Web.DonationGoal{}), do: true
  def includes?(:update, %CodeCorps.Web.DonationGoal{}), do: true
  def includes?(:create, %CodeCorps.Web.ProjectUser{}), do: true
  def includes?(:update, %CodeCorps.Web.ProjectUser{}), do: true
  def includes?(:create, %CodeCorps.Web.StripeConnectAccount{}), do: true
  def includes?(:create, %CodeCorps.Web.StripeConnectCharge{}), do: true
  def includes?(:create, %CodeCorps.Web.StripeConnectPlan{}), do: true
  def includes?(:create, %CodeCorps.Web.StripeConnectSubscription{}), do: true
  def includes?(:create, %CodeCorps.Web.StripePlatformCard{}), do: true
  def includes?(:create, %CodeCorps.Web.StripePlatformCustomer{}), do: true
  def includes?(:create, %CodeCorps.Web.Task{}), do: true
  def includes?(:update, %CodeCorps.Web.Task{}), do: true
  def includes?(:create, %CodeCorps.Web.User{}), do: true
  def includes?(:update, %CodeCorps.Web.User{}), do: true
  def includes?(:create, %CodeCorps.Web.UserCategory{}), do: true
  def includes?(:delete, %CodeCorps.Web.UserCategory{}), do: true
  def includes?(:create, %CodeCorps.Web.UserRole{}), do: true
  def includes?(:delete, %CodeCorps.Web.UserRole{}), do: true
  def includes?(:create, %CodeCorps.Web.UserSkill{}), do: true
  def includes?(:delete, %CodeCorps.Web.UserSkill{}), do: true
  def includes?(:create, %{token: _, user_id: _}), do: true
  def includes?(_, _), do: false
end
