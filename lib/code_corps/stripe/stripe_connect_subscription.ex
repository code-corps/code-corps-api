defmodule CodeCorps.Stripe.StripeConnectSubscription do
  alias CodeCorps.Project
  alias CodeCorps.Repo
  alias CodeCorps.Stripe.Adapters
  alias CodeCorps.StripeConnectAccount
  alias CodeCorps.StripeConnectCard
  alias CodeCorps.StripeConnectCustomer
  alias CodeCorps.StripeConnectPlan
  alias CodeCorps.StripeConnectSubscription
  alias CodeCorps.StripePlatformCard
  alias CodeCorps.StripePlatformCustomer

  import Ecto.Query

  @api Application.get_env(:code_corps, :stripe)

  def create(%{"project_id" => project_id, "quantity" => quantity, "stripe_platform_card_id" => stripe_platform_card_id, "user_id" => user_id} = attributes) do
    with %Project{stripe_connect_plan: %StripeConnectPlan{} = plan} = project <-
           get_project(project_id),
         %StripeConnectAccount{} = connect_account <-
           get_account_from_project(project),
         %StripePlatformCard{} = platform_card <-
           get_platform_card(stripe_platform_card_id),
         %StripePlatformCustomer{} = platform_customer <-
           get_platform_customer(user_id),
         {:ok, connect_customer} <-
           find_or_create_connect_customer(platform_customer, connect_account),
         {:ok, connect_card} <-
           find_or_create_connect_card(platform_card, connect_customer, platform_customer, connect_account),
         create_attributes <-
           to_create_attributes(connect_card, connect_customer, plan, quantity),
         {:ok, subscription} <-
           @api.Subscription.create(create_attributes, connect_account: connect_account.id_from_stripe),
         insert_attributes <-
           to_insert_attributes(attributes, plan),
         {:ok, params} <-
           Adapters.StripeConnectSubscription.to_params(subscription, insert_attributes)
    do
      %StripeConnectSubscription{}
      |> StripeConnectSubscription.create_changeset(params)
      |> Repo.insert
    else
      {:error, error} -> {:error, error}
      nil -> {:error, :not_found}
    end
  end

  defp get_project(project_id) do
    Project
    |> Repo.get(project_id)
    |> Repo.preload([:stripe_connect_plan, [{:organization, :stripe_connect_account}]])
  end

  defp get_platform_card(id) do
    StripePlatformCard
    |> Repo.get(id)
    |> Repo.preload(:stripe_connect_cards)
  end

  defp get_platform_customer(user_id) do
    StripePlatformCustomer
    |> Repo.get_by(user_id: user_id)
  end

  defp get_account_from_project(project) do
    project.organization.stripe_connect_account
  end

  defp find_or_create_connect_customer(%StripePlatformCustomer{} = customer, %StripeConnectAccount{} = account) do
    case get_connect_customer(account.id, customer.id) do
      %StripeConnectCustomer{} = existing_customer ->
        {:ok, existing_customer}
      nil ->
        CodeCorps.Stripe.StripeConnectCustomer.create(customer, account)
    end
  end

  defp get_connect_customer(account_id, customer_id) do
    StripeConnectCustomer
    |> where([c], c.stripe_connect_account_id == ^account_id)
    |> where([c], c.stripe_platform_customer_id == ^customer_id)
    |> Repo.one
  end

  defp find_or_create_connect_card(%StripePlatformCard{} = card, %StripeConnectCustomer{} = connect_customer, %StripePlatformCustomer{} = platform_customer, %StripeConnectAccount{} = account) do
    case get_connect_card(account.id, card.id) do
      %StripeConnectCard{} = existing_card ->
        {:ok, existing_card}
      nil ->
        CodeCorps.Stripe.StripeConnectCard.create(card, connect_customer, platform_customer, account)
    end
  end

  defp get_connect_card(account_id, card_id) do
    StripeConnectCard
    |> where([c], c.stripe_connect_account_id == ^account_id)
    |> where([c], c.stripe_platform_card_id == ^card_id)
    |> Repo.one
  end

  defp to_create_attributes(%StripeConnectCard{} = card, %StripeConnectCustomer{} = customer, %StripeConnectPlan{} = plan, quantity) do
    %{
      application_fee_percent: 5,
      customer: customer.id_from_stripe,
      plan: plan.id_from_stripe,
      quantity: quantity,
      source: card.id_from_stripe
    }
  end

  defp to_insert_attributes(attrs, %StripeConnectPlan{id: stripe_connect_plan_id}) do
    attrs |> Map.merge(%{"stripe_connect_plan_id" => stripe_connect_plan_id})
  end

  # TODO: Manual testing helpers, remove before merge

  def test do
    project = Project |> Repo.get(1)
    quantity = 10000
    user = CodeCorps.User |> Repo.get(4) |> Repo.preload([:stripe_platform_card])
    stripe_platform_card = user.stripe_platform_card

    create(%{
      "project_id" => project.id,
      "quantity" => quantity,
      "user_id" => user.id,
      "stripe_platform_card_id" => stripe_platform_card.id}
    )
  end

  def test_reset do
    CodeCorps.StripeConnectCard |> CodeCorps.Repo.all |> Enum.each(&CodeCorps.Repo.delete(&1))
    CodeCorps.StripeConnectCustomer |> CodeCorps.Repo.all |> Enum.each(&CodeCorps.Repo.delete(&1))
    CodeCorps.StripeConnectSubscription |> CodeCorps.Repo.all |> Enum.each(&CodeCorps.Repo.delete(&1))
  end

  def test_status do
    cards = CodeCorps.StripeConnectCard |> CodeCorps.Repo.aggregate(:count, :id)
    customers = CodeCorps.StripeConnectCustomer |> CodeCorps.Repo.aggregate(:count, :id)
    subscriptions = CodeCorps.StripeConnectSubscription |> CodeCorps.Repo.aggregate(:count, :id)

    IO.puts("\nCustomers: #{customers}, Cards: #{cards}, Subscriptions: #{subscriptions}\n")
  end
end
