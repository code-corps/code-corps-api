defmodule CodeCorps.StripeService.StripeConnectSubscriptionService do
  import Ecto.Query

  alias CodeCorps.{
    Organization, Project, Repo, StripeConnectAccount,StripeConnectCard,
    StripeConnectCustomer, StripeConnectPlan, StripeConnectSubscription,
    StripePlatformCard, StripePlatformCustomer, User
  }
  alias CodeCorps.Services.ProjectService
  alias CodeCorps.StripeService.{
    StripeConnectCardService, StripeConnectCustomerService
  }
  alias CodeCorps.StripeService.Adapters.StripeConnectSubscriptionAdapter

  @api Application.get_env(:code_corps, :stripe)

  def find_or_create(%{"project_id" => project_id, "quantity" => quantity, "user_id" => user_id} = attributes) do
    with %Project{
           stripe_connect_plan: %StripeConnectPlan{} = plan,
           organization: %Organization{
             stripe_connect_account: %StripeConnectAccount{} = connect_account
           }
         } = project <-
           get_project(project_id),
         %User{
           stripe_platform_card: %StripePlatformCard{} = platform_card,
           stripe_platform_customer: %StripePlatformCustomer{} = platform_customer
         } = user <-
           get_user(user_id),
         {:ok, %StripeConnectSubscription{} = stripe_connect_subscription} <-
           do_find_or_create(attributes, connect_account, plan, project, platform_card, platform_customer, quantity, user),
         _project <-
           ProjectService.update_project_totals(project)
    do
      {:ok, stripe_connect_subscription}
    else
      {:error, error} -> {:error, error}
      nil -> {:error, :not_found}
    end
  end

  defp do_find_or_create(%{"project_id" => _, "quantity" => _, "user_id" => _} = attributes, %StripeConnectAccount{} = connect_account, %StripeConnectPlan{} = plan, %Project{} = project, %StripePlatformCard{} = platform_card, %StripePlatformCustomer{} = platform_customer, quantity, %User{} = user) do
    case find(plan, user) do
      nil -> create(attributes, connect_account, plan, project, user, platform_card, platform_customer, quantity)
      %StripeConnectSubscription{} = subscription -> {:ok, subscription}
    end
  end

  defp find(%StripeConnectPlan{} = plan, %User{} = user) do
    StripeConnectSubscription
    |> where([s], s.stripe_connect_plan_id == ^plan.id and s.user_id == ^user.id)
    |> Repo.one
  end

  defp create(%{"project_id" => _, "quantity" => _, "user_id" => _} = attributes, %StripeConnectAccount{} = connect_account, %StripeConnectPlan{} = plan, %Project{} = project, %StripePlatformCard{} = platform_card, %StripePlatformCustomer{} = platform_customer, quantity, %User{} = user) do
    with {:ok, connect_customer} <-
           StripeConnectCustomerService.find_or_create(platform_customer, connect_account),
         {:ok, connect_card} <-
           StripeConnectCardService.find_or_create(platform_card, connect_customer, platform_customer, connect_account),
         create_attributes <-
           to_create_attributes(connect_card, connect_customer, plan, quantity),
         {:ok, subscription} <-
           @api.Subscription.create(create_attributes, connect_account: connect_account.id_from_stripe),
         insert_attributes <-
           to_insert_attributes(attributes, plan),
         {:ok, params} <-
           StripeConnectSubscriptionAdapter.to_params(subscription, insert_attributes),
         {:ok, %StripeConnectSubscription{} = stripe_connect_subscription} <-
           insert_subscription(params)
    do
      {:ok, stripe_connect_subscription}
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

  defp get_user(user_id) do
    User
    |> Repo.get(user_id)
    |> Repo.preload([stripe_platform_card: :stripe_connect_cards])
    |> Repo.preload(:stripe_platform_customer)
  end

  defp insert_subscription(params) do
    %StripeConnectSubscription{}
    |> StripeConnectSubscription.create_changeset(params)
    |> Repo.insert
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
end
