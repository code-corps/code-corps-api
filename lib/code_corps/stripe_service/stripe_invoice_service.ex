defmodule CodeCorps.StripeService.StripeInvoiceService do

  alias CodeCorps.Repo
  alias CodeCorps.Web.{StripeConnectAccount, StripeConnectCustomer, StripeInvoice}
  alias CodeCorps.StripeService.Adapters.StripeInvoiceAdapter

  @api Application.get_env(:code_corps, :stripe)

  @spec create(binary, binary) :: {:ok, %StripeInvoice{}} | {:error, %Ecto.Changeset{}}
  def create(invoice_id_from_stripe, customer_id_from_stripe) do
    with account_id <- get_connect_account(customer_id_from_stripe),
         {:ok, %Stripe.Invoice{} = invoice} <- @api.Invoice.retrieve(invoice_id_from_stripe, connect_account: account_id),
         {:ok, params} <- StripeInvoiceAdapter.to_params(invoice)
    do
      %StripeInvoice{}
      |> StripeInvoice.create_changeset(params)
      |> Repo.insert
    else
      failure -> failure
    end
  end

  defp get_connect_account(customer_id_from_stripe) do
    %StripeConnectCustomer{stripe_connect_account: %StripeConnectAccount{id_from_stripe: stripe_connect_account_id}} =
      StripeConnectCustomer
      |> Repo.get_by(id_from_stripe: customer_id_from_stripe)
      |> Repo.preload([:stripe_connect_account])
    stripe_connect_account_id
  end
end
