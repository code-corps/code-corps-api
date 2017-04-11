defmodule CodeCorps.StripeService.Events.ConnectChargeSucceeded do
  @moduledoc """
  Performs everything required to handle a charge.succeeded webhook
  on Stripe Connect
  """
  alias CodeCorps.StripeService.StripeConnectChargeService
  alias CodeCorps.{Emails, Mailer, Web.StripeConnectCharge}

  @api Application.get_env(:code_corps, :stripe)

  def handle(%{data: %{object: %{id: id_from_stripe}}, user_id: connect_account_id_from_stripe}) do
    with {:ok, charge} <- create_charge(id_from_stripe, connect_account_id_from_stripe) do
      charge |> track_created

      charge
      |> try_create_receipt(connect_account_id_from_stripe)
      |> maybe_send_receipt
    else
      failure -> failure
    end
  end

  defp create_charge(id_from_stripe, account_id_from_stripe) do
    StripeConnectChargeService.create(id_from_stripe, account_id_from_stripe)
  end

  defp try_create_receipt(%StripeConnectCharge{invoice_id_from_stripe: invoice_id} = charge, account_id) do
    with {:ok, %Stripe.Invoice{} = invoice} <- retrieve_invoice(invoice_id, account_id),
         %Bamboo.Email{} = receipt <- Emails.ReceiptEmail.create(charge, invoice)
    do
      {:ok, charge, receipt}
    else
      failure -> failure
    end
  end

  defp retrieve_invoice(invoice_id, account_id) do
    @api.Invoice.retrieve(invoice_id, connect_account: account_id)
  end

  defp maybe_send_receipt({:ok, charge, receipt}) do
    with %Bamboo.Email{} = email <- receipt |> Mailer.deliver_now do
      {:ok, charge, email}
    end
  end
  defp maybe_send_receipt(other), do: other

  defp track_created(%StripeConnectCharge{user_id: user_id} = charge) do
    CodeCorps.Analytics.SegmentTracker.track(user_id, :create, charge)
  end
end
