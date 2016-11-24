defmodule CodeCorps.Stripe.StripeConnectSubscription do
  alias CodeCorps.Organization
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

  @api Application.get_env(:code_corps, :stripe)

  def create(%{"project_id" => project_id, "quantity" => quantity, "stripe_platform_card_id" => stripe_platform_card_id, "user_id" => user_id} = attributes) do
    with %Project{} = project <-
           get_project(project_id),
         connect_account <-
           get_account_from_project(project),
         platform_card <-
           get_platform_card(user_id),
         platform_customer <-
           get_platform_customer(user_id),
         {:ok, connect_customer} <-
           find_or_create_connect_customer(platform_customer, connect_account),
         {:ok, connect_card} <-
           find_or_create_connect_card(platform_card, connect_customer),
         create_attributes <-
           to_create_attributes(connect_card, connect_customer, project.stripe_connect_plan, quantity),
         {:ok, subscription} <-
           @api.Subscription.create(create_attributes, connect_account: connect_account.id_from_stripe),
         {:ok, params} <-
           Adapters.StripeConnectSubscription.to_params(subscription, attributes)
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
    |> Repo.preload([organization: :stripe_connect_account], :stripe_connect_plan)
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

  end

  defp get_connect_customer do

  end

  defp find_or_create_connect_card(%StripePlatformCard{} = card, %StripeConnectCustomer{} = customer) do

  end

  defp get_connect_card do

  end

  defp to_create_attributes(%StripeConnectCard{} = card, %StripeConnectCustomer{} = customer, %StripeConnectPlan{} = plan, quantity) do
    %{
      application_fee_percent: 5,
      customer: customer.id,
      plan: plan.id,
      quantity: quantity,
      source: card.id
    }
  end
end
