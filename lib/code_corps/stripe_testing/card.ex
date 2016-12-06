defmodule CodeCorps.StripeTesting.Card do
  def create(:customer, stripe_id, _stripe_token, _opts \\ []) do
    {:ok, do_create(stripe_id)}
  end

  defp do_create(stripe_id) do
    %Stripe.Card{
      id: stripe_id,
      address_city: nil,
      address_country: nil,
      address_line1: nil,
      address_line1_check: nil,
      address_line2: nil,
      address_state: nil,
      address_zip: nil,
      address_zip_check: nil,
      brand: "Visa",
      country: "US",
      customer: nil,
      cvc_check: "unchecked",
      dynamic_last4: nil,
      exp_month: 11,
      exp_year: 2016,
      funding: "credit",
      last4: "4242",
      metadata: {},
      name: nil,
      tokenization_method: nil
    }
  end

  def retrieve(:customer, owner_id, stripe_id, _opts \\ []) do
    {:ok, do_retrieve(owner_id, stripe_id)}
  end

  defp do_retrieve(owner_id, stripe_id) do
    %Stripe.Card{
      id: stripe_id,
      address_city: nil,
      address_country: nil,
      address_line1: nil,
      address_line1_check: nil,
      address_line2: nil,
      address_state: nil,
      address_zip: nil,
      address_zip_check: nil,
      brand: "Visa",
      country: "US",
      customer: owner_id,
      cvc_check: "unchecked",
      dynamic_last4: nil,
      exp_month: 12,
      exp_year: 2020,
      funding: "credit",
      last4: "4242",
      metadata: {},
      name: "John Doe",
      tokenization_method: nil
    }
  end

  def update(:customer, owner_id, stripe_id, attributes, _opts \\ []) do
    {:ok, do_update(owner_id, stripe_id, attributes)}
  end

  defp do_update(owner_id, stripe_id, %{name: name, exp_month: exp_month, exp_year: exp_year}) do
    %Stripe.Card{
      id: stripe_id,
      address_city: nil,
      address_country: nil,
      address_line1: nil,
      address_line1_check: nil,
      address_line2: nil,
      address_state: nil,
      address_zip: nil,
      address_zip_check: nil,
      brand: "Visa",
      country: "US",
      customer: owner_id,
      cvc_check: "unchecked",
      dynamic_last4: nil,
      exp_month: exp_month,
      exp_year: exp_year,
      funding: "credit",
      last4: "4242",
      metadata: {},
      name: name,
      tokenization_method: nil
    }
  end
end
