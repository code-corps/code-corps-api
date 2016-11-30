defmodule CodeCorps.StripeService.Validators.UserCanSubscribe do
  @moduledoc """
  Ensures a `CodeCorps.User` is able to subscribe to a `CodeCorps.Project`.
  """

  alias CodeCorps.{User, StripePlatformCard, StripePlatformCustomer}

  @doc """
  Determines if the provided `CodeCorps.User` is able to
  subscribe to a `CodeCorps.Project`

  For a user to be able to create subscriptions, they need to have
  their associated records properly set up

  These are:

  * `StripePlatformCard`
  * `StripePlatformCustomer`

  If the user has these relationships set up, it returns `{:ok, user}`

  In any other case, it returns {:error, :user_not_ready}
  """
  def validate(%User{} = user), do: do_validate(user)

  @invalid {:error, :user_not_ready}

  defp do_validate(%User{
    stripe_platform_card: %StripePlatformCard{},
    stripe_platform_customer: %StripePlatformCustomer{}
  } = user), do: {:ok, user}
  defp do_validate(_), do: @invalid
end
