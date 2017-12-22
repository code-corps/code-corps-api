defmodule CodeCorps.StripeService.Events.ConnectChargeSucceeded do
  @moduledoc """
  Performs everything required to handle a charge.succeeded webhook
  on Stripe Connect
  """

  alias SparkPost.Transmission
  alias CodeCorps.{
    SparkPost,
    StripeService.StripeConnectChargeService,
    StripeConnectCharge
  }

  @api Application.get_env(:code_corps, :stripe)

  def handle(%{data: %{object: %{id: id_from_stripe}}, user_id: connect_account_id_from_stripe}) do
    with {:ok, %StripeConnectCharge{} = charge} <- StripeConnectChargeService.create(id_from_stripe, connect_account_id_from_stripe) do
      charge |> track_created()
      charge |> try_send_receipt(connect_account_id_from_stripe)
    else
      failure -> failure
    end
  end

  defp track_created(%StripeConnectCharge{user_id: user_id} = charge) do
    CodeCorps.Analytics.SegmentTracker.track(user_id, :create, charge)
  end

  defp try_send_receipt(%StripeConnectCharge{invoice_id_from_stripe: invoice_id} = charge, account_id) do
    with {:ok, %Stripe.Invoice{} = invoice} <- @api.Invoice.retrieve(invoice_id, connect_account: account_id),
         {:ok, %Transmission.Response{} = response} <- charge |> SparkPost.send_receipt_email(invoice)
    do
      {:ok, charge, response}
    else
      failure -> failure
    end
  end

end
