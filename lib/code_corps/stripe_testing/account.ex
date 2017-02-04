defmodule CodeCorps.StripeTesting.Account do
  import CodeCorps.StripeTesting.Helpers

  def create(attributes) do
    {:ok, create_stripe_record(attributes)}
  end

  def retrieve("account_with_multiple_external_accounts") do
    {:ok, load_fixture(Stripe.Account, "account_with_multiple_external_accounts")}
  end

  def retrieve(id) do
    {:ok, create_stripe_record(%{"id" => id})}
  end

  def update(id, attributes) do
    {:ok, create_stripe_record(attributes |> Map.merge(%{id: id}))}
  end

  defp create_stripe_record(attributes) do
    transformed_attributes =
      attributes
      |> CodeCorps.MapUtils.keys_to_string
      |> Map.merge(account_fixture())
      |> add_nestings


    Stripe.Account |> Stripe.Converter.stripe_map_to_struct(transformed_attributes)
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
      "data" => [%{"id" => external_account_id, "object" => "bank_account"}],
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
