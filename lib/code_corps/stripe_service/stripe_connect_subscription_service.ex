defmodule CodeCorps.StripeService.StripeConnectSubscriptionService do
  @moduledoc """
  Used to perform actions on `StripeConnectSubscription` records while propagating
  to and from associated `Stripe.Subscription` records.
  """

  alias CodeCorps.Repo
  alias CodeCorps.Web.{
    Project, StripeConnectCustomer, StripeConnectAccount,
    StripeConnectPlan, StripeConnectSubscription, User
  }
  alias CodeCorps.Services.{DonationGoalsService, ProjectService}
  alias CodeCorps.StripeService.{StripeConnectCardService, StripeConnectCustomerService}
  alias CodeCorps.StripeService.Adapters.StripeConnectSubscriptionAdapter
  alias CodeCorps.StripeService.Validators.{ProjectSubscribable, UserCanSubscribe}

  @api Application.get_env(:code_corps, :stripe)

  @doc """
  Finds or creates a new `Stripe.Subscription` record on Stripe API, as well as an associated local
  `StripeConnectSubscription` record

  # Side effects

  - If the subscription is created or found, associated project totals will get updated
  - If the subscription is created or found, associated donation goal states will be updated
  """
  @spec find_or_create(map) :: {:ok, StripeConnectSubscription.t} |
                               {:error, Ecto.Changeset.t} |
                               {:error, Stripe.APIErrorResponse.t} |
                               {:error, :project_not_found} |
                               {:error, :project_not_ready} |
                               {:error, :user_not_found} |
                               {:error, :user_not_ready}
  def find_or_create(%{"project_id" => project_id, "quantity" => _, "user_id" => user_id} = attributes) do
    with {:ok, %Project{} = project} <- get_project_with_preloads(project_id),
         {:ok, %Project{}} <- ProjectSubscribable.validate(project),
         {:ok, %User{} = user} <- get_user_with_preloads(user_id),
         {:ok, %User{}} <- UserCanSubscribe.validate(user)
    do
      {:ok, %StripeConnectSubscription{} = subscription} = do_find_or_create(project, user, attributes)

      ProjectService.update_project_totals(project)
      DonationGoalsService.update_project_goals(project)

      {:ok, subscription}
    else
      failure -> failure
    end
  end

  @doc """
  Updates an existing `StripeConnectSubscription` record by retrieving
  a `Stripe.Subscription` record and using that data as update parameters
  """
  @spec update_from_stripe(String.t, String.t) :: {:ok, StripeConnectSubscription.t} |
                                                  {:error, Stripe.APIErrorResponse.t} |
                                                  {:error, :not_found}
  def update_from_stripe(stripe_id, connect_customer_id) do
    with {:ok, %StripeConnectAccount{} = connect_account} <- retrieve_connect_account(connect_customer_id),
         {:ok, %Stripe.Subscription{} = stripe_subscription} <- @api.Subscription.retrieve(stripe_id, connect_account: connect_account.id),
         {:ok, %StripeConnectSubscription{stripe_connect_plan: %{project: project}} = subscription} <- load_subscription(stripe_id),
         {:ok, params} <- stripe_subscription |> StripeConnectSubscriptionAdapter.to_params(%{})
    do
      {:ok, %StripeConnectSubscription{} = subscription} = update_subscription(subscription, params)

      ProjectService.update_project_totals(project)
      DonationGoalsService.update_project_goals(project)

      {:ok, subscription}
    else
      failure -> failure
    end
  end

  # find_or_create

  defp do_find_or_create(project, user, attributes) do
    case find(project.stripe_connect_plan, user) do
      nil -> create(project, user, attributes)
      %StripeConnectSubscription{} = subscription -> {:ok, subscription}
    end
  end

  defp find(plan, user) do
    StripeConnectSubscription
    |> Repo.get_by(stripe_connect_plan_id: plan.id, user_id: user.id)
  end

  defp create(project, user, attributes) do
    with platform_card <- user.stripe_platform_card,
         platform_customer <- user.stripe_platform_customer,
         connect_account <- project.organization.stripe_connect_account,
         plan <- project.stripe_connect_plan,
         {:ok, connect_customer} <- StripeConnectCustomerService.find_or_create(platform_customer, connect_account, user),
         {:ok, connect_card} <- StripeConnectCardService.find_or_create(platform_card, connect_customer, platform_customer, connect_account),
         create_attributes <- api_create_attributes(connect_card, connect_customer, plan, attributes),
         {:ok, subscription} <- @api.Subscription.create(create_attributes, connect_account: connect_account.id_from_stripe),
         insert_attributes <- local_insert_attributes(attributes, plan),
         {:ok, params} <- StripeConnectSubscriptionAdapter.to_params(subscription, insert_attributes),
         {:ok, %StripeConnectSubscription{} = stripe_connect_subscription} <- insert_subscription(params)
    do
      {:ok, stripe_connect_subscription}
    else
      # just pass failure to caller
      failure -> failure
    end
  end

  defp get_project_with_preloads(id) do
    preloads = [:stripe_connect_plan, [organization: :stripe_connect_account]]

    case Project |> Repo.get(id) |> Repo.preload(preloads) do
      nil -> {:error, :project_not_found}
      project -> {:ok, project}
    end
  end

  defp get_user_with_preloads(user_id) do
    preloads = [:stripe_platform_customer, [{:stripe_platform_card, :stripe_connect_cards}]]

    case User |> Repo.get(user_id) |> Repo.preload(preloads) do
      nil -> {:error, :user_not_found}
      user -> {:ok, user}
    end
  end

  defp insert_subscription(params) do
    %StripeConnectSubscription{}
    |> StripeConnectSubscription.create_changeset(params)
    |> Repo.insert
  end

  defp api_create_attributes(card, customer, plan, %{"quantity" => quantity}) do
    %{
      application_fee_percent: 5,
      customer: customer.id_from_stripe,
      plan: plan.id_from_stripe,
      quantity: quantity,
      source: card.id_from_stripe
    }
  end

  defp local_insert_attributes(attrs, %StripeConnectPlan{id: stripe_connect_plan_id}) do
    attrs |> Map.merge(%{"stripe_connect_plan_id" => stripe_connect_plan_id})
  end

  # update_from_stripe

  defp retrieve_connect_account(connect_customer_id) do
    customer =
      StripeConnectCustomer
      |> Repo.get_by(id_from_stripe: connect_customer_id)
      |> Repo.preload(:stripe_connect_account)

    {:ok, customer.stripe_connect_account}
  end

  defp load_subscription(id_from_stripe) do
    subscription =
      StripeConnectSubscription
      |> Repo.get_by(id_from_stripe: id_from_stripe)
      |> Repo.preload([stripe_connect_plan: [project: [:stripe_connect_plan, :donation_goals]]])

    {:ok, subscription}
  end

  defp update_subscription(%StripeConnectSubscription{} = record, params) do
    record
    |> StripeConnectSubscription.webhook_update_changeset(params)
    |> Repo.update
  end
end
