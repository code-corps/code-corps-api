defmodule CodeCorps.StripeService.Adapters.StripeInvoiceAdapter do
  alias CodeCorps.Repo
  alias CodeCorps.Web.{StripeConnectCustomer, StripeConnectSubscription}

  import CodeCorps.MapUtils, only: [keys_to_string: 1]
  import CodeCorps.StripeService.Util, only: [transform_map: 2]

  # Mapping of stripe record attributes to locally stored attributes
  # Format is {:local_key, [:nesting, :of, :stripe, :keys]}
  @stripe_mapping [
    {:id_from_stripe, [:id]},
    {:amount_due, [:amount_due]},
    {:application_fee, [:application_fee]},
    {:attempt_count, [:attempt_count]},
    {:attempted, [:attempted]},
    {:charge_id_from_stripe, [:charge]},
    {:closed, [:closed]},
    {:currency, [:currency]},
    {:customer_id_from_stripe, [:customer]},
    {:date, [:date]},
    {:description, [:description]},
    {:ending_balance, [:ending_balance]},
    {:forgiven, [:forgiven]},
    {:next_payment_attempt, [:next_payment_attempt]},
    {:paid, [:paid]},
    {:period_end, [:period_end]},
    {:period_start, [:period_start]},
    {:receipt_number, [:receipt_number]},
    {:starting_balance, [:starting_balance]},
    {:statement_descriptor, [:statement_descriptor]},
    {:subscription_id_from_stripe, [:subscription]},
    {:subscription_proration_date, [:subscription_proration_date]},
    {:subtotal, [:subtotal]},
    {:tax, [:tax]},
    {:tax_percent, [:tax_percent]},
    {:total, [:total]},
    {:webhooks_delivered_at, [:webhooks_delivered_at]},
  ]

  @doc """
  Transforms a `%Stripe.Invoice{}` and a set of local attributes into a
  map of parameters used to create or update a `StripeInvoice` record.
  """
  def to_params(%Stripe.Invoice{} = stripe_invoice) do
    result =
      stripe_invoice
      |> Map.from_struct
      |> transform_map(@stripe_mapping)
      |> add_stripe_connect_subscription_id
      |> add_user_id
      |> keys_to_string

    {:ok, result}
  end

  defp add_stripe_connect_subscription_id(%{subscription_id_from_stripe: subscription_id_from_stripe} = map) do
    %StripeConnectSubscription{id: id} =
      StripeConnectSubscription
      |> Repo.get_by(id_from_stripe: subscription_id_from_stripe)
    Map.put(map, :stripe_connect_subscription_id, id)
  end

  defp add_user_id(%{customer_id_from_stripe: customer_id_from_stripe} = map) do
    %StripeConnectCustomer{user_id: user_id} =
      StripeConnectCustomer
      |> Repo.get_by(id_from_stripe: customer_id_from_stripe)
    Map.put(map, :user_id, user_id)
  end
end
