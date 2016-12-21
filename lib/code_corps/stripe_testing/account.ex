defmodule CodeCorps.StripeTesting.Account do
  def create(_map) do
    {:ok, create_stripe_record(%{})}
  end

  def retrieve(id) do
    {:ok, create_stripe_record(%{"id" => id})}
  end

  def update(id, attributes) do
    attributes =
      attributes
      |> CodeCorps.MapUtils.keys_to_string
      |> Map.merge(%{"id" => id})

    {:ok, create_stripe_record(attributes)}
  end

  defp create_stripe_record(attributes) do
    with attributes <- account_fixture |> Map.merge(attributes) |> add_nestings
    do
      Stripe.Account |> Stripe.Converter.stripe_map_to_struct(attributes)
    end
  end

  defp account_fixture do
    %{
      "business_name" => "Code Corps PBC",
      "business_primary_color" => nil,
      "business_url" => "codecorps.org",
      "charges_enabled" => true,
      "country" => "US",
      "default_currency" => "usd",
      "details_submitted" => true,
      "display_name" => "Code Corps Customer",
      "email" => "volunteers@codecorps.org",
      "external_accounts" => %{
        "object" => "list",
        "data" => [],
        "has_more" => false,
        "total_count" => 0,
        "url" => "/v1/accounts/acct_123/external_accounts"
      },
      "id" => "acct_123",
      "managed" => true,
      "metadata" => %{},
      "statement_descriptor" => "CODECORPS.ORG",
      "support_email" => nil,
      "support_phone" => "1234567890",
      "support_url" => nil,
      "timezone" => "America/Los_Angeles",
      "transfers_enabled" => true
    }
  end

  defp add_nestings(map) do
    map
    |> add_external_account
  end

  defp add_external_account(%{"id" => account_id, "external_account" => external_account_id} = map) do
    external_accounts_map = %{
      "object" => "list",
      "data" => [%{"id" => external_account_id}],
      "has_more" => false,
      "total_count" => 1,
      "url" => "/v1/accounts/#{account_id}/external_accounts"
    }

    Map.put(map, "external_accounts", external_accounts_map)
  end
  defp add_external_account(%{"id" => account_id} = map) do
    external_accounts_map = %{
      "object" => "list",
      "data" => [],
      "has_more" => false,
      "total_count" => 1,
      "url" => "/v1/accounts/#{account_id}/external_accounts"
    }

    Map.put(map, "external_accounts", external_accounts_map)
  end
end
