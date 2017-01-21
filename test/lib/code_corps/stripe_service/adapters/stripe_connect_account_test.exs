defmodule CodeCorps.StripeService.Adapters.StripeConnectAccountTest do
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
    external_accounts: %Stripe.List{
      data: [
        %Stripe.ExternalAccount{id: "ba_123"}
      ],
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
      business_tax_id: "000000000",
      business_tax_id_provided: true,
      business_vat_id: "000000000",
      business_vat_id_provided: true,
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
    tos_acceptance: %{
      date: 123456,
      ip: "127.0.0.1",
      user_agent: "Chrome"
    },
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

  defp test_account do
    # If a `Stripe.Account` has multiple `Stripe.ExternalAccount` records, we want
    # the adapter to deal with that by only taking one, so we load the appropriate fixture
    CodeCorps.StripeTesting.Helpers.load_fixture(Stripe.Account, "account_with_multiple_external_accounts")
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
      expected_attributes = %{"organization_id" => 123,}

      {:ok, result} = to_params(test_account, test_attributes)
      expected_map = Map.merge(@local_map, expected_attributes)

      assert result == expected_map
    end
  end
end
