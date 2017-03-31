defmodule CodeCorps.StripeService.Adapters.StripeConnectChargeAdapter do

  alias CodeCorps.Repo
  alias CodeCorps.StripeService.Util
  alias CodeCorps.Web{StripeConnectAccount, StripeConnectCustomer}

  # Mapping of stripe record attributes to locally stored attributes
  # Format is {:local_key, [:nesting, :of, :stripe, :keys]}
  #
  # TODO:
  #
  # Relationships we have
  # * customer, user
  # Relationship we store but do not define
  # * application, invoice, connect account, balance transaction, source transfer, transfer
  @stripe_mapping [
    {:amount, [:amount]},
    {:amount_refunded, [:amount_refunded]},
    {:application_id_from_stripe, [:application]},
    {:application_fee_id_from_stripe, [:application_fee]},
    {:balance_transaction_id_from_stripe, [:balance_transaction]},
    {:captured, [:captured]},
    {:created, [:created]},
    {:currency, [:currency]},
    {:customer_id_from_stripe, [:customer]},
    {:description, [:description]},
    {:failure_code, [:failure_code]},
    {:failure_message, [:failure_message]},
    {:id_from_stripe, [:id]},
    {:invoice_id_from_stripe, [:invoice]},
    {:paid, [:paid]},
    {:refunded, [:refunded]},
    {:review_id_from_stripe, [:review]},
    {:source_transfer_id_from_stripe, [:source_transfer]},
    {:statement_descriptor, [:statement_descriptor]},
    {:status, [:status]}
  ]

  @doc """
  Transforms a `%Stripe.Charge{}` and a set of local attributes into a
  map of parameters used to create or update a `StripeConnectCharge` record.
  """
  def to_params(%Stripe.Charge{} = stripe_charge, %StripeConnectAccount{id: connect_account_id}) do
    result =
      stripe_charge
      |> Map.from_struct
      |> Util.transform_map(@stripe_mapping)
      |> Map.put(:stripe_connect_account_id, connect_account_id)
      |> add_other_associations()

    {:ok, result}
  end

  defp add_other_associations(%{customer_id_from_stripe: customer_id_from_stripe} = attributes) do
    %StripeConnectCustomer{id: customer_id, user_id: user_id} =
      Repo.get_by(StripeConnectCustomer, id_from_stripe: customer_id_from_stripe)

    attributes
    |> Map.put(:user_id, user_id)
    |> Map.put(:stripe_connect_customer_id, customer_id)
  end
end
