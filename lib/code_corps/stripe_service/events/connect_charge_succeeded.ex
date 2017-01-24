defmodule CodeCorps.StripeService.Events.ConnectChargeSucceeded do
  alias CodeCorps.StripeService.StripeConnectChargeService
  alias CodeCorps.{Emails, Mailer, StripeConnectCharge}

  @api Application.get_env(:code_corps, :stripe)

  def handle(%{data: %{object: %{id: id_from_stripe}}, user_id: connect_account_id_from_stripe}) do
    create_charge(id_from_stripe, connect_account_id_from_stripe)
    |> try_create_receipt(connect_account_id_from_stripe)
    |> try_send_receipt
  end

  defp create_charge(id_from_stripe, account_id_from_stripe) do
    StripeConnectChargeService.create(id_from_stripe, account_id_from_stripe)
  end

  defp try_create_receipt({:ok, %StripeConnectCharge{invoice_id_from_stripe: invoice_id} = charge}, account_id) do
    with {:ok, %Stripe.Invoice{} = invoice} <- retrieve_invoice(invoice_id, account_id),
         %Bamboo.Email{} = receipt <- Emails.ReceiptEmail.create(charge, invoice)
    do
      {:ok, charge, receipt}
    else
      failure -> failure
    end
  end
  defp try_create_receipt(any, _account_id), do: any

  defp retrieve_invoice(invoice_id, account_id) do
    @api.Invoice.retrieve(invoice_id, connect_account: account_id)
  end

  defp try_send_receipt({:ok, charge, receipt}) do
    with %Bamboo.Email{} = email <- receipt |> Mailer.deliver_now do
      {:ok, charge, email}
    end
  end
  defp try_send_receipt(other), do: other
end
