defmodule CodeCorps.StripeTesting.Account do
  alias CodeCorps.StripeTesting.Helpers

  @extra_keys ~w(business_logo business_primary_color support_url transfer_schedule transfer_statement_descriptor)

  def create(attributes) do
    {:ok, create_stripe_record(attributes)}
  end

  def retrieve("account_with_multiple_external_accounts") do
    {:ok, load_fixture("account_with_multiple_external_accounts")}
  end

  def retrieve(id) do
    {:ok, create_stripe_record(%{"id" => id})}
  end

  def update(id, attributes) do
    {:ok, create_stripe_record(attributes |> Map.merge(%{id: id}))}
  end

  def load_fixture(id) do
    id
    |> Helpers.load_raw_fixture
    |> Map.drop(@extra_keys)
    |> Stripe.Converter.convert_result
  end

  defp create_stripe_record(attributes) do
    transformed_attributes =
      attributes
      |> CodeCorps.MapUtils.keys_to_string
      |> Map.merge("account" |> Helpers.load_raw_fixture)
      |> add_external_account
      |> Map.drop(@extra_keys)

    Stripe.Converter.convert_result(transformed_attributes)
  end

  defp add_external_account(%{"id" => account_id, "external_account" => external_account_id} = map) do
    external_accounts_map = %{
      "object" => "list",
      "data" => [%{"id" => external_account_id, "object" => "bank_account"}],
      "has_more" => false,
      "total_count" => 1,
      "url" => "/v1/accounts/#{account_id}/external_accounts"
    }

    map
    |> Map.put("external_accounts", external_accounts_map)
    |> Map.drop(["external_account"])
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
