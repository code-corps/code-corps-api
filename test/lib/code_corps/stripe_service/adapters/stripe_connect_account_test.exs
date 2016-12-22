defmodule CodeCorps.StripeService.Adapters.StripeConnectAccountTestAdapter do
  use ExUnit.Case, async: true

  import CodeCorps.StripeService.Adapters.StripeConnectAccountAdapter, only: [to_params: 2]

  @stripe_connect_account %Stripe.Account{
    id: "acct_123",
    business_name: "Code Corps PBC",
    business_url: "codecorps.org",
    charges_enabled: false,
    country: "US",
    default_currency: "usd",
    details_submitted: false,
    display_name: "Code Corps",
    email: "volunteers@codecorps.org",
    external_accounts: %{
      object: "list",
      data: [%{"id" => "ba_123"}],
      has_more: false,
      total_count: 0,
      url: "/v1/accounts/acct_123/external_accounts"
    },
    legal_entity: %{
      address: %{
        city: nil,
        country: "US",
        line1: nil,
        line2: nil,
        postal_code: nil,
        state: nil
      },
      business_name: nil,
      business_tax_id_provided: false,
      dob: %{
        day: nil,
        month: nil,
        year: nil
      },
      first_name: nil,
      last_name: nil,
      personal_address: %{
        city: nil,
        country: "US",
        line1: nil,
        line2: nil,
        postal_code: nil,
        state: nil
      },
      personal_id_number_provided: false,
      ssn_last_4_provided: false,
      type: nil,
      verification: %{
        details: nil,
        details_code: "failed_other",
        document: "fil_12345",
        status: "unverified"
      }
    },
    id: "acct_123",
    managed: false,
    statement_descriptor: nil,
    support_email: nil,
    support_phone: "1234567890",
    timezone: "US/Pacific",
    transfers_enabled: false,
    verification: %{
      disabled_reason: "fields_needed",
      due_by: nil,
      fields_needed: [
        "business_url",
        "external_account",
        "product_description",
        "support_phone",
        "tos_acceptance.date",
        "tos_acceptance.ip"
      ]
    }
  }

  @local_map %{
    "id_from_stripe" => "acct_123",

    "business_name" => "Code Corps PBC",
    "business_url" => "codecorps.org",
    "charges_enabled" => false,
    "country" => "US",
    "default_currency" => "usd",
    "details_submitted" => false,
    "display_name" => "Code Corps",
    "email" => "volunteers@codecorps.org",

    "external_account" => "ba_123",

    "legal_entity_address_city" => nil,
    "legal_entity_address_country" => "US",
    "legal_entity_address_line1" => nil,
    "legal_entity_address_line2" => nil,
    "legal_entity_address_postal_code" => nil,
    "legal_entity_address_state" => nil,

    "legal_entity_business_name" => nil,
    "legal_entity_business_tax_id_provided" => false,
    "legal_entity_business_vat_id_provided" => nil,

    "legal_entity_dob_day" => nil,
    "legal_entity_dob_month" => nil,
    "legal_entity_dob_year" => nil,

    "legal_entity_first_name" => nil,
    "legal_entity_gender" => nil,
    "legal_entity_last_name" => nil,
    "legal_entity_maiden_name" => nil,

    "legal_entity_personal_address_city" => nil,
    "legal_entity_personal_address_country" => "US",
    "legal_entity_personal_address_line2" => nil,
    "legal_entity_personal_address_line1" => nil,
    "legal_entity_personal_address_postal_code" => nil,
    "legal_entity_personal_address_state" => nil,

    "legal_entity_personal_id_number_provided" => false,

    "legal_entity_phone_number" => nil,

    "legal_entity_ssn_last_4_provided" => false,

    "legal_entity_type" => nil,

    "legal_entity_verification_details" => nil,
    "legal_entity_verification_details_code" => "failed_other",
    "legal_entity_verification_document" => "fil_12345",
    "legal_entity_verification_status" => "unverified",

    "managed" => false,

    "support_email" => nil,
    "support_phone" => "1234567890",
    "support_url" => nil,

    "transfers_enabled" => false,

    "verification_disabled_reason" => "fields_needed",
    "verification_due_by" => nil,
    "verification_fields_needed" => [
      "business_url",
      "external_account",
      "product_description",
      "support_phone",
      "tos_acceptance.date",
      "tos_acceptance.ip"
    ]
  }

  describe "to_params/2" do
    test "converts from stripe map to local properly" do
      test_attributes = %{
        "organization_id" => 123,
        "foo" => "bar"
      }
      expected_attributes = %{
        "organization_id" => 123,
      }

      {:ok, result} = to_params(@stripe_connect_account, test_attributes)
      expected_map = Map.merge(@local_map, expected_attributes)

      assert result == expected_map
    end
  end
end
