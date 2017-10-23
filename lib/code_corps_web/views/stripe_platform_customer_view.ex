defmodule CodeCorpsWeb.StripePlatformCustomerView do
  @moduledoc false
  use CodeCorpsWeb.PreloadHelpers, default_preloads: [:user]
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:created, :currency, :delinquent, :email, :id_from_stripe, :inserted_at, :updated_at]

  has_one :user, serializer: CodeCorpsWeb.UserView

  @doc """
  Returns the email or an empty string, depending on the stripe_platform_customer record
  being rendered is the authenticated user's record, or some other user's.

  Users can only see their own emails. Everyone else's are private.
  """
  def email(stripe_platform_customer, %Plug.Conn{assigns: %{current_user: current_user}}) do
    if stripe_platform_customer.user == current_user, do: stripe_platform_customer.email, else: ""
  end
  def email(_stripe_platform_customer, _conn), do: ""

  @doc """
  Returns the id_from_stripe or an empty string, depending on the stripe_platform_customer record
  being rendered is the authenticated user's record, or some other user's.

  Users can only see their own stripe ids. Everyone else's are private.
  """
  def id_from_stripe(stripe_platform_customer, %Plug.Conn{assigns: %{current_user: current_user}}) do
    if stripe_platform_customer.user_id == current_user.id, do: stripe_platform_customer.id_from_stripe, else: ""
  end
  def id_from_stripe(_stripe_platform_customer, _conn), do: ""
end
