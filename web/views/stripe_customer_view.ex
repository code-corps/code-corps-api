defmodule CodeCorps.StripeCustomerView do
  use CodeCorps.PreloadHelpers, default_preloads: [:user]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:created, :currency, :delinquent, :email, :id_from_stripe, :inserted_at, :updated_at]

  has_one :user, serializer: CodeCorps.UserView

  @doc """
  Returns the email or an empty string, depending on the stripe_customer record
  being rendered is the authenticated user's record, or some other user's.

  Users can only see their own emails. Everyone else's are private.
  """
  def email(stripe_customer, %Plug.Conn{assigns: %{current_user: current_user}}) do
    if stripe_customer.user == current_user, do: stripe_customer.email, else: ""
  end
  def email(_stripe_customer, _conn), do: ""

  @doc """
  Returns the id_from_stripe or an empty string, depending on the stripe_customer record
  being rendered is the authenticated user's record, or some other user's.

  Users can only see their own stripe ids. Everyone else's are private.
  """
  def id_from_stripe(stripe_customer, %Plug.Conn{assigns: %{current_user: current_user}}) do
    if stripe_customer.user_id == current_user.id, do: stripe_customer.id_from_stripe, else: ""
  end
  def id_from_stripe(_stripe_customer, _conn), do: ""
end
