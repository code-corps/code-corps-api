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

  def to_managed_params(%Stripe.Account{} = stripe_account, %{} = attributes) do
    params = %{
      email: stripe_account.email,
      managed: stripe_account.managed,
      # TODO: A stripe response will not return the business_ein. instead,
      # it will return business_tax_id_provided, which is a boolean. we should probably store that,
      # not this
      business_ein: attributes |> Map.get("business_ein"),
      business_name: stripe_account.legal_entity.business_name, # or stripe_account.business_name

      # as far as I can tell, stripe does not store this. might wanna remove it from the whole process.
      # added it due to looking at kickstarter form
      business_type: attributes |> Map.get("business_type"),

      first_name: stripe_account.legal_entity.first_name,
      last_name: stripe_account.legal_entity.last_name,
      # TODO: A stripe response will not return the ssn_last4. instead,
      # it will return ssn_last4_provided, which is a boolean. we should probably store that,
      # not this
      ssn_last4: attributes |> Map.get("ssn_last4"),
      recipient_type: stripe_account.legal_entity.type,

      # TODO: decide on getting legal_entity.address or legal_entity.personal_address
      address1: stripe_account.legal_entity.address.line1,
      address2: stripe_account.legal_entity.address.line2,
      city: stripe_account.legal_entity.address.city,
      country: stripe_account.legal_entity.address.country,
      state: stripe_account.legal_entity.address.state,
      # we maybe wanna rename this one
      zip: stripe_account.legal_entity.address.postal_code,

      dob_day: stripe_account.legal_entity.dob.day,
      dob_month: stripe_account.legal_entity.dob.month,
      dob_year: stripe_account.legal_entity.dob.year,

      id_from_stripe: stripe_account.id,
      charges_enabled: stripe_account.charges_enabled,
      transfers_enabled: stripe_account.transfers_enabled,

      organization_id: attributes |> Map.get("organization_id"),
    }

    IO.inspect(params)
    {:ok, params}
  end

  def to_stripe_params(%{
    "country" => country,
    "email" => email
  } = attributes) do
    with legal_entity <- build_legal_entity(attributes)
    do
      params = %{ country: country, email: email, managed: true, legal_entity: legal_entity}
      {:ok, params}
    end
  end
  def to_stripe_managed_params(attributes) do
    {:error, :fields_missing}
  end

  defp build_legal_entity(%{
    "business_ein" => business_ein, "business_name" => business_name, "business_type" => _,
    "first_name" => first_name, "last_name" => last_name, "ssn_last4" => ssn_last4,
    "recipient_type" => recipient_type
  } = attributes) do
    with address <- build_address(attributes),
         dob <- build_dob(attributes)
    do
      %{
        business_name: business_name,
        business_tax_id: business_ein,
        dob: dob,
        first_name: first_name,
        last_name: last_name,
        ssn_last_4: ssn_last4,
        type: recipient_type,
        # TODO: Decide which address to set
        address: address,
        personal_address: address
      }
    end
  end

  defp build_dob(%{"dob_day" => dob_day, "dob_month" => dob_month, "dob_year" => dob_year}) do
    %{day: dob_day, month: dob_month, year: dob_year}
  end

  defp build_address(%{
    "address1" => address1, "address2" => address2, "city" => city,
    "country" => country, "state" => state,"zip" => zip
  }) do
    %{city: city, country: country, line1: address1, line2: address2, postal_code: zip, state: state}
  end

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
