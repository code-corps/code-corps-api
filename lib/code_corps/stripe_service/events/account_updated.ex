defmodule CodeCorps.StripeService.Events.AccountUpdated do
  alias CodeCorps.StripeService.Adapters
  alias CodeCorps.StripeConnectAccount
  alias CodeCorps.Repo

  @api Application.get_env(:code_corps, :stripe)

  # def handle(%{"data" => %{"object" => %{"livemode" => false}}}), do: {:ok, :ignored_not_live}
  def handle(%{"data" => data}) do
    stripe_account = data |> retrieve_account
    local_account = data |> load_account

    local_account |> update(stripe_account)
  end

  defp retrieve_account(%{"object" => %{"id" => id_from_stripe}}) do
    # hardcoded for testing
    id_from_stripe = "acct_19JlxsFTVVt7Lv80"

    {:ok, stripe_account} = @api.Account.retrieve(id_from_stripe)
    stripe_account
  end

  defp load_account(%{"object" => %{"id" => id_from_stripe}}) do
     # hardcoded for testing
    id_from_stripe = "acct_19JlxsFTVVt7Lv80"

    StripeConnectAccount
    |> Repo.get_by(id_from_stripe: id_from_stripe)
  end

  defp update(%StripeConnectAccount{} = record, %Stripe.Account{} = stripe_account) do
    {:ok, params} =
      stripe_account
      |> Adapters.StripeConnectAccount.to_params(%{})

    record
    |> StripeConnectAccount.webhook_update_changeset(params)
    |> Repo.update
  end
end

account = %{
  "business_logo" => nil,
  "business_name" => nil,
  "business_url" => nil,
  "charges_enabled" => false,
  "country" => "US",
  "debit_negative_balances" => true,
  "decline_charge_on" => %{
    "avs_failure" => false, "cvc_failure" => true
  },
  "default_currency" => "usd",
  "details_submitted" => true,
  "display_name" => nil,
  "email" => "test@stripe.com",
  "external_accounts" => %{
    "data" => [],
    "has_more" => false,
    "object" => "list",
    "total_count" => 0,
    "url" => "/v1/accounts/acct_17XohmBKl1F6IRFf/external_accounts"
  },
  "id" => "acct_00000000000000",
  "legal_entity" => %{
    "address" => %{
      "city" => nil,
      "country" => "US",
      "line1" => nil,
      "line2" => nil,
      "postal_code" => nil,
      "state" => nil
    },
    "business_name" => nil,
    "business_tax_id_provided" => false,
    "dob" => %{
      "day" => nil,
      "month" => nil,
      "year" => nil
    },
    "first_name" => nil,
    "last_name" => nil,
    "personal_address" => %{
      "city" => nil,
      "country" => "US",
      "line1" => nil,
      "line2" => nil,
      "postal_code" => nil,
      "state" => nil
    },
    "personal_id_number_provided" => false,
    "ssn_last_4_provided" => false,
    "type" => nil,
    "verification" => %{
      "details" => nil,
      "details_code" => nil,
      "document" => nil,
      "status" => "unverified"
    }
  },
  "managed" => false,
  "object" => "account",
  "product_description" => nil,
  "statement_descriptor" => "TEST",
  "support_email" => nil,
  "support_phone" => nil,
  "timezone" => "Europe/Zagreb",
  "tos_acceptance" => %{
    "date" => nil,
    "ip" => nil,
    "user_agent" => nil
  },
  "transfer_schedule" => %{
    "delay_days" => 2,
    "interval" => "daily"
  },
  "transfer_statement_descriptor" => nil,
  "transfers_enabled" => false,
  "verification" => %{
    "disabled_reason" => "fields_needed",
    "due_by" => 1480345118,
    "fields_needed" => [
      "legal_entity.verification.document"
    ]
  }
}

previous_attributes = %{
  "verification" => %{
    "due_by" => nil,
    "fields_needed" => []
  }
}

event = %{
  "api_version" => "2016-07-06",
  "created" => 1326853478,
  "data" => %{
    "object" => account,
    "previous_attributes" => previous_attributes
  },
  "id" => "evt_00000000000000",
  "livemode" => false,
  "object" => "event",
  "pending_webhooks" => 1,
  "request" => nil,
  "type" => "account.updated"
}
