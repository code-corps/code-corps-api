defmodule CodeCorps.StripeService.StripeConnectSubscriptionService do
  import Ecto.Query

  alias CodeCorps.{
    Project, Repo, StripeConnectCard, StripeConnectCustomer,
    StripeConnectPlan, StripeConnectSubscription, User
  }
  alias CodeCorps.Services.ProjectService
  alias CodeCorps.StripeService.{StripeConnectCardService, StripeConnectCustomerService}
  alias CodeCorps.StripeService.Adapters.StripeConnectSubscriptionAdapter
  alias CodeCorps.StripeService.Validators.{ProjectSubscribable, UserCanSubscribe}

  @api Application.get_env(:code_corps, :stripe)

  def find_or_create(%{"project_id" => project_id, "quantity" => _, "user_id" => user_id} = attributes) do
    with {:ok, %Project{} = project} <- get_project_with_preloads(project_id) |> ProjectSubscribable.validate,
         {:ok, %User{} = user} <- get_user_with_preloads(user_id) |> UserCanSubscribe.validate
    do
      {:ok, %StripeConnectSubscription{} = stripe_connect_subscription} = do_find_or_create(project, user, attributes)
      ProjectService.update_project_totals(project)
      {:ok, stripe_connect_subscription}
    else
      {:error, :project_not_ready} -> {:error, :project_not_ready}
      {:error, :user_not_ready} -> {:error, :user_not_ready}
      {:error, error} -> {:error, error}
      nil -> {:error, :not_found}
    end
  end

  defp do_find_or_create(%Project{} = project, %User{} = user, %{} = attributes) do
    case find(project, user) do
      nil -> create(project, user, attributes)
      %StripeConnectSubscription{} = subscription -> {:ok, subscription}
    end
  end

  defp find(%Project{} = project, %User{} = user) do
    StripeConnectSubscription
    |> where([s], s.stripe_connect_plan_id == ^project.stripe_connect_plan.id and s.user_id == ^user.id)
    |> Repo.one
  end

  defp create(%Project{} = project, %User{} = user, attributes) do
    with platform_card <- user.stripe_platform_card,
         platform_customer <- user.stripe_platform_customer,
         connect_account <- project.organization.stripe_connect_account,
         plan <- project.stripe_connect_plan,
         {:ok, connect_customer} <- StripeConnectCustomerService.find_or_create(platform_customer, connect_account),
         {:ok, connect_card} <- StripeConnectCardService.find_or_create(platform_card, connect_customer, platform_customer, connect_account),
         create_attributes <- to_create_attributes(connect_card, connect_customer, plan, attributes),
         {:ok, subscription} <- @api.Subscription.create(create_attributes, connect_account: connect_account.id_from_stripe),
         insert_attributes <- to_insert_attributes(attributes, plan),
         {:ok, params} <- StripeConnectSubscriptionAdapter.to_params(subscription, insert_attributes),
         {:ok, %StripeConnectSubscription{} = stripe_connect_subscription} <- insert_subscription(params)
    do
      {:ok, stripe_connect_subscription}
    else
      {:error, error} -> {:error, error}
      nil -> {:error, :not_found}
    end
  end

  @default_project_preloads [:stripe_connect_plan, [{:organization, :stripe_connect_account}]]

  defp get_project_with_preloads(project_id, preloads \\ @default_project_preloads) do
    Project
    |> Repo.get(project_id)
    |> Repo.preload(preloads)
  end

  @default_user_preloads [:stripe_platform_customer, [{:stripe_platform_card, :stripe_connect_cards}]]

  defp get_user_with_preloads(user_id, preloads \\ @default_user_preloads) do
    User
    |> Repo.get(user_id)
    |> Repo.preload(preloads)
  end

  defp insert_subscription(params) do
    %StripeConnectSubscription{}
    |> StripeConnectSubscription.create_changeset(params)
    |> Repo.insert
  end

  defp to_create_attributes(
    %StripeConnectCard{} = card,
    %StripeConnectCustomer{} = customer,
    %StripeConnectPlan{} = plan,
    %{"quantity" => quantity}
  ) do
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
