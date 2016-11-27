defmodule CodeCorps.StripeService.Events.CustomerSubscriptionUpdated do
  import Ecto.Query

  alias CodeCorps.Project
  alias CodeCorps.Repo
  alias CodeCorps.StripeConnectPlan
  alias CodeCorps.StripeConnectSubscription
  alias CodeCorps.StripeService.Adapters

  @api Application.get_env(:code_corps, :stripe)

  # def handle(%{"data" => %{"object" => %{"livemode" => false}}}), do: {:ok, :ignored_not_live}
  def handle(%{"data" => %{"object" => %{"id" => connect_subscription_id, "customer" => connect_customer_id}}}) do
    {:ok, stripe_subscription} = retrieve_subscription(connect_subscription_id, connect_customer_id)
    {:ok, params} = stripe_subscription |> Adapters.StripeConnectSubscription.to_params(%{})

    {:ok, subscription} = connect_customer_id |> load_subscription |> update_subscription(params)
    {:ok, project} = subscription |> get_project |> update_project_totals

    {:ok, subscription, project}
  end

  defp retrieve_subscription(connect_subscription_id,  connect_customer_id) do
    # hardcoded for testing
    connect_subscription_id = "sub_9d23Hm0TiyrMY4"
    connect_customer_id = "cus_9d23RTnbRtp5mk"

    connect_customer =
      CodeCorps.StripeConnectCustomer
      |> CodeCorps.Repo.get_by(id_from_stripe: connect_customer_id)
      |> CodeCorps.Repo.preload(:stripe_connect_account)

    connect_account_id = connect_customer.stripe_connect_account.id_from_stripe

    @api.Subscription.retrieve(connect_subscription_id, connect_account: connect_account_id)
  end

  defp load_subscription(id_from_stripe) do
     # hardcoded for testing
    id_from_stripe = "sub_9d23Hm0TiyrMY4"

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
      |> Repo.preload(:project)

    plan.project
  end

  defp update_project_totals(%Project{id: project_id} = project) do
    total_monthly_donated =
      StripeConnectSubscription
      |> where([s], s.status=="active")
      |> Repo.aggregate(:sum, :quantity)

    project
    |> Project.update_total_changeset(%{total_monthly_donated: total_monthly_donated})
    |> Repo.update
  end
end

old_subscription_attributes = %{
  "plan" => %{
    "amount" => 1,
    "created" => 1479981880,
    "currency" => "usd",
    "id" => "OLD_PLAN_ID",
    "interval" => "month",
    "interval_count" => 1,
    "livemode" => false,
    "metadata" => %{},
    "name" => "Old plan",
    "object" => "plan",
    "statement_descriptor" => nil,
    "trial_period_days" => nil
  }
}

current_subscription_attributes = %{
  "application_fee_percent" => nil,
  "cancel_at_period_end" => false,
  "canceled_at" => nil,
  "created" => 1480085925,
  "current_period_end" => 1482677925,
  "current_period_start" => 1480085925,
  "customer" => "cus_00000000000000",
  "discount" => nil,
  "ended_at" => nil,
  "id" => "sub_00000000000000",
  "livemode" => false,
  "metadata" => %{},
  "object" => "subscription",
  "plan" => %{
    "amount" => 1,
    "created" => 1479981880,
    "currency" => "usd",
    "id" => "month_00000000000000",
    "interval" => "month",
    "interval_count" => 1,
    "livemode" => false,
    "metadata" => %{},
    "name" => "Monthly donation to Code Corps.", "object" => "plan",
    "statement_descriptor" => nil,
    "trial_period_days" => nil
  },
  "quantity" => 1,
  "start" => 1480085925,
  "status" => "active",
  "tax_percent" => nil,
  "trial_end" => nil,
  "trial_start" => nil
}

event = %{
  "api_version" => "2016-07-06",
  "created" => 1326853478,
  "data" => %{
    "object" => current_subscription_attributes,
    "previous_attributes" => old_subscription_attributes
  },
  "id" => "evt_00000000000000",
  "livemode" => false,
  "object" => "event",
  "pending_webhooks" => 1, "request" => nil,
  "type" => "customer.subscription.updated"
}
