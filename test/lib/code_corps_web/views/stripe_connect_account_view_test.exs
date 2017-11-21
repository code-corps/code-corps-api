defmodule CodeCorpsWeb.StripeConnectAccountViewTest do
  @moduledoc false

  use CodeCorpsWeb.ViewCase

  test "renders all attributes and relationships properly" do
    organization = insert(:organization)
    account = insert(:stripe_connect_account,
      organization: organization,
      verification_disabled_reason: "fields_needed",
      verification_fields_needed: ["legal_entity.first_name", "legal_entity.last_name"]
    )
    insert(:stripe_external_account,
      stripe_connect_account: account,
      bank_name: "Wells Fargo",
      last4: "1234",
      routing_number: "123456789"
    )

    account = CodeCorpsWeb.StripeConnectAccountController.preload(account)
    rendered_json = render(CodeCorpsWeb.StripeConnectAccountView, "show.json-api", data: account)

    expected_json = %{
      "data" => %{
        "attributes" => %{
          "bank-account-bank-name" => "Wells Fargo",
          "bank-account-last4" => "1234",
          "bank-account-routing-number" => "123456789",
          "bank-account-status" => "pending_requirement",
          "business-name" => account.business_name,
          "business-url" => account.business_url,
          "can-accept-donations" => true,
          "charges-enabled" => account.charges_enabled,
          "country" => account.country,
          "default-currency" => account.default_currency,
          "details-submitted" => account.details_submitted,
          "display-name" => account.display_name,
          "email" => account.email,
          "id-from-stripe" => account.id_from_stripe,
          "inserted-at" => account.inserted_at,
          "legal-entity-address-city" => account.legal_entity_address_city,
          "legal-entity-address-country" => account.legal_entity_address_country,
          "legal-entity-address-line1" => account.legal_entity_address_line1,
          "legal-entity-address-line2" => account.legal_entity_address_line2,
          "legal-entity-address-postal-code" => account.legal_entity_address_postal_code,
          "legal-entity-address-state" => account.legal_entity_address_state,
          "legal-entity-business-name" => account.legal_entity_business_name,
          "legal-entity-business-tax-id" => account.legal_entity_business_tax_id,
          "legal-entity-business-tax-id-provided" => account.legal_entity_business_tax_id_provided,
          "legal-entity-business-vat-id" => account.legal_entity_business_vat_id,
          "legal-entity-business-vat-id-provided" => account.legal_entity_business_vat_id_provided,
          "legal-entity-dob-day" => account.legal_entity_dob_day,
          "legal-entity-dob-month" => account.legal_entity_dob_month,
          "legal-entity-dob-year" => account.legal_entity_dob_year,
          "legal-entity-first-name" => account.legal_entity_first_name,
          "legal-entity-last-name" => account.legal_entity_last_name,
          "legal-entity-gender" => account.legal_entity_gender,
          "legal-entity-maiden-name" => account.legal_entity_maiden_name,
          "legal-entity-personal-address-city" => account.legal_entity_personal_address_city,
          "legal-entity-personal-address-country" => account.legal_entity_personal_address_country,
          "legal-entity-personal-address-line1" => account.legal_entity_personal_address_line1,
          "legal-entity-personal-address-line2" => account.legal_entity_personal_address_line2,
          "legal-entity-personal-address-postal-code" => account.legal_entity_personal_address_postal_code,
          "legal-entity-personal-address-state" => account.legal_entity_personal_address_state,
          "legal-entity-phone-number" => account.legal_entity_phone_number,
          "legal-entity-personal-id-number" => account.legal_entity_personal_id_number,
          "legal-entity-personal-id-number-provided" => account.legal_entity_personal_id_number_provided,
          "legal-entity-ssn-last-4" => account.legal_entity_ssn_last_4,
          "legal-entity-ssn-last-4-provided" => account.legal_entity_ssn_last_4_provided,
          "legal-entity-type" => account.legal_entity_type,
          "legal-entity-verification-details" => account.legal_entity_verification_details,
          "legal-entity-verification-details-code" => account.legal_entity_verification_details_code,
          "legal-entity-verification-document" => account.legal_entity_verification_document,
          "legal-entity-verification-status" => account.legal_entity_verification_status,
          "payouts-enabled" => account.payouts_enabled,
          "personal-id-number-status" => "pending_requirement",
          "recipient-status" => "required",
          "support-email" => account.support_email,
          "support-phone" => account.support_phone,
          "support-url" => account.support_url,
          "type" => account.type,
          "updated-at" => account.updated_at,
          "verification-disabled-reason" => account.verification_disabled_reason,
          "verification-document-status" => "pending_requirement",
          "verification-due-by" => account.verification_due_by,
          "verification-fields-needed" => account.verification_fields_needed
        },
        "id" => account.id |> Integer.to_string,
        "relationships" => %{
          "organization" => %{
            "data" => %{"id" => organization.id |> Integer.to_string, "type" => "organization"}
          }
        },
        "type" => "stripe-connect-account",
      },
      "jsonapi" => %{
        "version" => "1.0"
      }
    }

    assert rendered_json == expected_json
  end

  test "renders can-accept-donations as true in prod when charges-enabled is true" do
    Application.put_env(:code_corps, :stripe_env, :prod)

    organization = insert(:organization)
    account = insert(:stripe_connect_account, organization: organization, charges_enabled: true)

    account = CodeCorpsWeb.StripeConnectAccountController.preload(account)
    rendered_json = render(CodeCorpsWeb.StripeConnectAccountView, "show.json-api", data: account)
    assert rendered_json["data"]["attributes"]["can-accept-donations"] == true
    assert rendered_json["data"]["attributes"]["charges-enabled"] == true

    Application.put_env(:code_corps, :stripe_env, :test)
  end

  test "renders can-accept-donations as false in prod when charges-enabled is false" do
    Application.put_env(:code_corps, :stripe_env, :prod)

    organization = insert(:organization)
    account = insert(:stripe_connect_account, organization: organization, charges_enabled: false)

    account = CodeCorpsWeb.StripeConnectAccountController.preload(account)
    rendered_json = render(CodeCorpsWeb.StripeConnectAccountView, "show.json-api", data: account)
    assert rendered_json["data"]["attributes"]["can-accept-donations"] == false
    assert rendered_json["data"]["attributes"]["charges-enabled"] == false

    Application.put_env(:code_corps, :stripe_env, :test)
  end

  test "renders can-accept-donations as true in test when charges-enabled is false" do
    organization = insert(:organization)
    account = insert(:stripe_connect_account, organization: organization, charges_enabled: false)

    account = CodeCorpsWeb.StripeConnectAccountController.preload(account)
    rendered_json = render(CodeCorpsWeb.StripeConnectAccountView, "show.json-api", data: account)
    assert rendered_json["data"]["attributes"]["can-accept-donations"] == true
    assert rendered_json["data"]["attributes"]["charges-enabled"] == false
  end

  describe "recipient-status" do
    test "renders as 'required' by default" do
      account = insert(:stripe_connect_account, legal_entity_verification_status: "unverified")
      account = CodeCorpsWeb.StripeConnectAccountController.preload(account)
      rendered_json = render(CodeCorpsWeb.StripeConnectAccountView, "show.json-api", data: account)
      assert rendered_json["data"]["attributes"]["recipient-status"] == "required"
    end

    test "renders as 'required' when fields_needed includes personal_id_number" do
      account = insert(:stripe_connect_account, legal_entity_verification_status: "pending", verification_fields_needed: ["legal_entity.personal_id_number"])
      account = CodeCorpsWeb.StripeConnectAccountController.preload(account)
      rendered_json = render(CodeCorpsWeb.StripeConnectAccountView, "show.json-api", data: account)
      assert rendered_json["data"]["attributes"]["recipient-status"] == "required"
    end

    test "renders as 'required' when fields_needed includes verification.document" do
      account = insert(:stripe_connect_account, legal_entity_verification_status: "pending", verification_fields_needed: ["legal_entity.verification.document"])
      account = CodeCorpsWeb.StripeConnectAccountController.preload(account)
      rendered_json = render(CodeCorpsWeb.StripeConnectAccountView, "show.json-api", data: account)
      assert rendered_json["data"]["attributes"]["recipient-status"] == "required"
    end

    test "renders as 'verified' when fields_needed does not include a legal_entity field" do
      account = insert(:stripe_connect_account, legal_entity_verification_status: "pending", verification_fields_needed: [])
      account = CodeCorpsWeb.StripeConnectAccountController.preload(account)
      rendered_json = render(CodeCorpsWeb.StripeConnectAccountView, "show.json-api", data: account)
      assert rendered_json["data"]["attributes"]["recipient-status"] == "verified"
    end

    test "renders as 'verified' when verification status is 'verified'" do
      account = insert(:stripe_connect_account, legal_entity_verification_status: "verified")
      account = CodeCorpsWeb.StripeConnectAccountController.preload(account)
      rendered_json = render(CodeCorpsWeb.StripeConnectAccountView, "show.json-api", data: account)
      assert rendered_json["data"]["attributes"]["recipient-status"] == "verified"
    end
  end

  describe "verification-document-status" do
    test "renders as 'pending_requirement' by default" do
      account = insert(:stripe_connect_account)
      account = CodeCorpsWeb.StripeConnectAccountController.preload(account)
      rendered_json = render(CodeCorpsWeb.StripeConnectAccountView, "show.json-api", data: account)
      assert rendered_json["data"]["attributes"]["verification-document-status"] == "pending_requirement"
    end

    test "renders as 'pending_requirement' when appropriate" do
      account = insert(
        :stripe_connect_account,
        legal_entity_verification_document: nil,
        verification_fields_needed: ["legal_entity.type"])
      account = CodeCorpsWeb.StripeConnectAccountController.preload(account)
      rendered_json = render(CodeCorpsWeb.StripeConnectAccountView, "show.json-api", data: account)
      assert rendered_json["data"]["attributes"]["verification-document-status"] == "pending_requirement"
    end

    test "renders as 'required' when appropriate" do
      account = insert(
        :stripe_connect_account,
        legal_entity_verification_document: nil,
        verification_fields_needed: ["legal_entity.verification.document"])
      account = CodeCorpsWeb.StripeConnectAccountController.preload(account)
      rendered_json = render(CodeCorpsWeb.StripeConnectAccountView, "show.json-api", data: account)
      assert rendered_json["data"]["attributes"]["verification-document-status"] == "required"
    end

    test "renders as 'verifying' when appropriate" do
      account = insert(
        :stripe_connect_account,
        legal_entity_verification_document: "file_123",
        legal_entity_verification_status: "pending",
        verification_fields_needed: ["legal_entity.verification.document"])
      account = CodeCorpsWeb.StripeConnectAccountController.preload(account)
      rendered_json = render(CodeCorpsWeb.StripeConnectAccountView, "show.json-api", data: account)
      assert rendered_json["data"]["attributes"]["verification-document-status"] == "verifying"
    end

    test "renders as 'verified' when the verification status is verified" do
      account = insert(
        :stripe_connect_account,
        legal_entity_verification_status: "verified")
      account = CodeCorpsWeb.StripeConnectAccountController.preload(account)
      rendered_json = render(CodeCorpsWeb.StripeConnectAccountView, "show.json-api", data: account)
      assert rendered_json["data"]["attributes"]["verification-document-status"] == "verified"
    end

    test "renders as 'verified' when there's a document and document is not required" do
      account = insert(
        :stripe_connect_account,
        legal_entity_verification_document: "file_123",
        verification_fields_needed: ["legal_entity.personal_id_number"])
      account = CodeCorpsWeb.StripeConnectAccountController.preload(account)
      rendered_json = render(CodeCorpsWeb.StripeConnectAccountView, "show.json-api", data: account)
      assert rendered_json["data"]["attributes"]["verification-document-status"] == "verified"
    end

    test "renders as 'errored' when appropriate" do
      account = insert(
        :stripe_connect_account,
        legal_entity_verification_document: "file_123",
        verification_fields_needed: ["legal_entity.verification.document"])
      account = CodeCorpsWeb.StripeConnectAccountController.preload(account)
      rendered_json = render(CodeCorpsWeb.StripeConnectAccountView, "show.json-api", data: account)
      assert rendered_json["data"]["attributes"]["verification-document-status"] == "errored"
    end
  end

  describe "personal-id-number-status" do
    test "renders as 'pending_requirement' by default" do
      account = insert(:stripe_connect_account)
      account = CodeCorpsWeb.StripeConnectAccountController.preload(account)
      rendered_json = render(CodeCorpsWeb.StripeConnectAccountView, "show.json-api", data: account)
      assert rendered_json["data"]["attributes"]["personal-id-number-status"] == "pending_requirement"
    end

    test "renders as 'pending_requirement' when appropriate" do
      account = insert(
        :stripe_connect_account,
        legal_entity_personal_id_number_provided: false,
        verification_fields_needed: ["legal_entity.type"])
      account = CodeCorpsWeb.StripeConnectAccountController.preload(account)
      rendered_json = render(CodeCorpsWeb.StripeConnectAccountView, "show.json-api", data: account)
      assert rendered_json["data"]["attributes"]["personal-id-number-status"] == "pending_requirement"
    end

    test "renders as 'required' when appropriate" do
      account = insert(
        :stripe_connect_account,
        legal_entity_personal_id_number_provided: false,
        verification_fields_needed: ["legal_entity.personal_id_number"])
      account = CodeCorpsWeb.StripeConnectAccountController.preload(account)
      rendered_json = render(CodeCorpsWeb.StripeConnectAccountView, "show.json-api", data: account)
      assert rendered_json["data"]["attributes"]["personal-id-number-status"] == "required"
    end

    test "renders as 'verifying' when appropriate" do
      account = insert(
        :stripe_connect_account,
        legal_entity_personal_id_number_provided: true,
        legal_entity_verification_status: "pending")
      account = CodeCorpsWeb.StripeConnectAccountController.preload(account)
      rendered_json = render(CodeCorpsWeb.StripeConnectAccountView, "show.json-api", data: account)
      assert rendered_json["data"]["attributes"]["personal-id-number-status"] == "verifying"
    end

    test "renders as 'verified' when appropriate" do
      account = insert(
        :stripe_connect_account,
        legal_entity_personal_id_number_provided: true,
        verification_fields_needed: ["external_account"])
      account = CodeCorpsWeb.StripeConnectAccountController.preload(account)
      rendered_json = render(CodeCorpsWeb.StripeConnectAccountView, "show.json-api", data: account)
      assert rendered_json["data"]["attributes"]["personal-id-number-status"] == "verified"
    end
  end

  describe "bank-account-status" do
    test "renders as 'pending_requirement' by default" do
      account = insert(:stripe_connect_account)
      account = CodeCorpsWeb.StripeConnectAccountController.preload(account)
      rendered_json = render(CodeCorpsWeb.StripeConnectAccountView, "show.json-api", data: account)
      assert rendered_json["data"]["attributes"]["bank-account-status"] == "pending_requirement"
    end

    test "renders as 'pending_requirement' when appropriate" do
      account = insert(
        :stripe_connect_account,
        legal_entity_verification_status: "pending",
        verification_fields_needed: ["legal_entity.personal_id_number"])
      account = CodeCorpsWeb.StripeConnectAccountController.preload(account)
      rendered_json = render(CodeCorpsWeb.StripeConnectAccountView, "show.json-api", data: account)
      assert rendered_json["data"]["attributes"]["bank-account-status"] == "pending_requirement"
    end

    test "renders as 'required' when appropriate" do
      account = insert(
        :stripe_connect_account,
        legal_entity_verification_status: "verified",
        verification_fields_needed: ["external_account"])
      account = CodeCorpsWeb.StripeConnectAccountController.preload(account)
      rendered_json = render(CodeCorpsWeb.StripeConnectAccountView, "show.json-api", data: account)
      assert rendered_json["data"]["attributes"]["bank-account-status"] == "required"
    end

    test "renders as 'verified' when appropriate" do
      account = insert(
        :stripe_connect_account,
        external_account: "ba_123")
      account = CodeCorpsWeb.StripeConnectAccountController.preload(account)
      rendered_json = render(CodeCorpsWeb.StripeConnectAccountView, "show.json-api", data: account)
      assert rendered_json["data"]["attributes"]["bank-account-status"] == "verified"
    end
  end

  describe "external account fields" do
    test "render if there is an associated external account" do
      account = insert(:stripe_connect_account)
      insert(:stripe_external_account, last4: "ABCD", routing_number: "123456", stripe_connect_account: account)

      account = CodeCorpsWeb.StripeConnectAccountController.preload(account)
      rendered_json = render(CodeCorpsWeb.StripeConnectAccountView, "show.json-api", data: account)

      assert rendered_json["data"]["attributes"]["bank-account-last4"] == "ABCD"
      assert rendered_json["data"]["attributes"]["bank-account-routing-number"] == "123456"
    end
  end
end
