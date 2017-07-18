defmodule CodeCorps.StripeService.Adapters.StripeConnectAccountTest do
  use ExUnit.Case, async: true

  alias CodeCorps.StripeService.Adapters.StripeConnectAccountAdapter

  defp test_account() do
    # If a `Stripe.Account` has multiple `Stripe.ExternalAccount` records, we want
    # the adapter to deal with that by only taking one, so we load the appropriate fixture
    CodeCorps.StripeTesting.Helpers.load_fixture("account_with_multiple_external_accounts")
  end

  @local_map %{
    "id_from_stripe" => "account_with_multiple_external_accounts",

    "business_name" => "Some Company Inc.",
    "business_url" => "somecompany.org",
    "charges_enabled" => false,
    "country" => "US",
    "default_currency" => "usd",
    "details_submitted" => false,
    "display_name" => "Code Corps",
    "email" => "someone@mail.com",

    "external_account" => "ba_222222222222222222222222",

    "legal_entity_address_city" => nil,
    "legal_entity_address_country" => "US",
    "legal_entity_address_line1" => nil,
    "legal_entity_address_line2" => nil,
    "legal_entity_address_postal_code" => nil,
    "legal_entity_address_state" => nil,

    "legal_entity_business_name" => "Some Company Inc.",
    "legal_entity_business_tax_id" => nil,
    "legal_entity_business_tax_id_provided" => false,
    "legal_entity_business_vat_id" => nil,
    "legal_entity_business_vat_id_provided" => false,

    "legal_entity_dob_day" => nil,
    "legal_entity_dob_month" => nil,
    "legal_entity_dob_year" => nil,

    "legal_entity_first_name" => "John",
    "legal_entity_gender" => nil,
    "legal_entity_last_name" => "Doe",
    "legal_entity_maiden_name" => nil,

    "legal_entity_personal_address_city" => nil,
    "legal_entity_personal_address_country" => "US",
    "legal_entity_personal_address_line2" => nil,
    "legal_entity_personal_address_line1" => nil,
    "legal_entity_personal_address_postal_code" => nil,
    "legal_entity_personal_address_state" => nil,

    "legal_entity_personal_id_number" => nil,
    "legal_entity_personal_id_number_provided" => false,

    "legal_entity_phone_number" => nil,

    "legal_entity_ssn_last_4" => nil,
    "legal_entity_ssn_last_4_provided" => false,

    "legal_entity_type" => "sole_prop",

    "legal_entity_verification_details" => nil,
    "legal_entity_verification_details_code" => "failed_other",
    "legal_entity_verification_document" => "fil_12345",
    "legal_entity_verification_status" => "unverified",

    "managed" => true,

    "support_email" => nil,
    "support_phone" => "1234567890",
    "support_url" => nil,

    "transfers_enabled" => false,

    "tos_acceptance_date" => nil,
    "tos_acceptance_ip" => nil,
    "tos_acceptance_user_agent" => nil,

    "verification_disabled_reason" => "fields_needed",
    "verification_due_by" => nil,
    "verification_fields_needed" => [
      "business_url",
      "external_account",
      "tos_acceptance.date",
      "tos_acceptance.ip"
    ]
  }

  describe "to_params/2" do
    test "converts from stripe map to local properly" do
      test_attributes = %{"organization_id" => 123, "foo" => "bar"}
      expected_attributes = %{"organization_id" => 123}

      {:ok, result} = StripeConnectAccountAdapter.to_params(test_account(), test_attributes)
      expected_map = Map.merge(@local_map, expected_attributes)

      assert result == expected_map
    end
  end

  describe "from_params/1" do
    test "converts from local to stripe map properly" do
      # add some junk data to ensure that gets removed
      test_input = Map.merge(@local_map, %{"organization_id" => 123, "foo" => "bar"})

      {:ok, result} = StripeConnectAccountAdapter.from_params(test_input)

      assert result == %{
        business_name: "Some Company Inc.",
        business_url: "somecompany.org",
        charges_enabled: false,
        country: "US",
        default_currency: "usd",
        details_submitted: false,
        display_name: "Code Corps",
        email: "someone@mail.com",
        id: "account_with_multiple_external_accounts",
        managed: true,
        support_phone: "1234567890",
        transfers_enabled: false,
        legal_entity: %{
          business_name: "Some Company Inc.",
          business_tax_id_provided: false,
          business_vat_id_provided: false,
          first_name: "John",
          last_name: "Doe",
          personal_id_number_provided: false,
          ssn_last_4_provided: false,
          type: "sole_prop",
          address: %{country: "US"},
          personal_address: %{country: "US"},
          verification: %{details_code: "failed_other", document: "fil_12345", status: "unverified"}
        },
        verification: %{
          disabled_reason: "fields_needed",
          fields_needed: ["business_url", "external_account", "tos_acceptance.date", "tos_acceptance.ip"]
        },
        external_account: "ba_222222222222222222222222"
      }
    end
  end
end
