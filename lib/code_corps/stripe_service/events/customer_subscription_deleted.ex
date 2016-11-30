defmodule CodeCorps.StripeService.Events.CustomerSubscriptionDeleted do
  alias CodeCorps.Project
  alias CodeCorps.Repo
  alias CodeCorps.Services.DonationGoalsService
  alias CodeCorps.Services.ProjectService
  alias CodeCorps.StripeConnectAccount
  alias CodeCorps.StripeConnectCustomer
  alias CodeCorps.StripeConnectPlan
  alias CodeCorps.StripeConnectSubscription
  alias CodeCorps.StripeService.Adapters.StripeConnectSubscriptionAdapter

  @api Application.get_env(:code_corps, :stripe)

  def handle(%{"data" => %{"object" => %{"id" => stripe_sub_id, "customer" => connect_customer_id}}}) do
    with %StripeConnectCustomer{stripe_connect_account: %StripeConnectAccount{id_from_stripe: connect_account_id}} <-
           retrieve_connect_customer(connect_customer_id),

         {:ok, %Stripe.Subscription{} = stripe_subscription} <-
           @api.Subscription.retrieve(stripe_sub_id, connect_account: connect_account_id),

         subscription <-
           load_subscription(stripe_sub_id),

         {:ok, params} <-
           stripe_subscription |> StripeConnectSubscriptionAdapter.to_params(%{}),

         _subscription <-
           update_subscription(subscription, params),

         project <-
           get_project(subscription),

         {:ok, project} <-
           ProjectService.update_project_totals(project)
    do
      DonationGoalsService.update_project_goals(project)
    else
      {:error, %Stripe.APIErrorResponse{}} -> {:error, :stripe_error}
      nil -> {:error, :not_found}
      _ -> {:error, :unexpected}
    end
  end

  defp retrieve_connect_customer(connect_customer_id) do
    StripeConnectCustomer
    |> Repo.get_by(id_from_stripe: connect_customer_id)
    |> Repo.preload(:stripe_connect_account)
  end

  defp load_subscription(id_from_stripe) do
    StripeConnectSubscription
    |> Repo.get_by(id_from_stripe: id_from_stripe)
  end

  defp update_subscription(%StripeConnectSubscription{} = record, params) do
    record
    |> StripeConnectSubscription.webhook_update_changeset(params)
    |> Repo.update
  end

  defp get_project(%StripeConnectSubscription{stripe_connect_plan_id: stripe_connect_plan_id}) do
    plan =
      StripeConnectPlan
      |> Repo.get(stripe_connect_plan_id)

    Project |> Repo.get(plan.project_id) |> Repo.preload(:stripe_connect_plan)
  end
end
