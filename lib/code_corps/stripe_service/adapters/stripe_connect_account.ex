defmodule CodeCorps.StripeService.Adapters.StripeConnectAccountAdapter do
  import CodeCorps.MapUtils, only: [rename: 3, keys_to_string: 1]

  @stripe_attributes [
    :business_name, :business_url, :charges_enabled, :country, :default_currency, :details_submitted, :email, :id, :managed,
    :support_email, :support_phone, :support_url, :transfers_enabled
  ]

  def to_params(%Stripe.Account{} = stripe_account, %{} = attributes) do
    result =
      stripe_account
      |> Map.from_struct
      |> Map.take(@stripe_attributes)
      |> rename(:id, :id_from_stripe)
      |> keys_to_string
      |> add_non_stripe_attributes(attributes)

    {:ok, result}
  end

  def to_managed_params(%{
    "address1" => address1,
    "address2" => address2,
    "business_ein" => business_ein,
    "business_name" => business_name,
    "business_type" => _,
    "city" => city,
    "country" => country,
    "dob_day" => dob_day,
    "dob_month" => dob_month,
    "dob_year" => dob_year,
    "email" => email,
    "first_name" => first_name,
    "last_name" => last_name,
    "recipient_type" => recipient_type,
    "ssn_last4" => ssn_last4,
    "state" => state,
    "zip" => zip,
    "organization_id" => _
  } = attributes) do

    address = %{city: city, country: country, line1: address1, line2: address2, postal_code: zip, state: state}

    params = %{
      country: country,
      email: email,
      managed: true,
      legal_entity: %{
        business_name: business_name,
        business_tax_id: business_ein,
        dob: %{day: dob_day, month: dob_month, year: dob_year},
        first_name: first_name,
        last_name: last_name,
        ssn_last4: ssn_last4
      }
    } |> put_address(recipient_type, address)

    {:ok, params}
  end
  def to_managed_params(attributes) do
    IO.inspect(attributes, pretty: true)
    {:error, :fields_missing}
  end

  defp put_address(params, "individual", address), do: params |> Map.put(:personal_address, address)
  defp put_address(params, "company", address), do: params |> Map.put(:address, address)

  @non_stripe_attributes ["organization_id"]

  defp add_non_stripe_attributes(%{} = params, %{} = attributes) do
    attributes
    |> get_non_stripe_attributes
    |> add_to(params)
  end

  defp get_non_stripe_attributes(%{} = attributes) do
    attributes
    |> Map.take(@non_stripe_attributes)
  end

  defp add_to(%{} = attributes, %{} = params) do
    params
    |> Map.merge(attributes)
  end
end
