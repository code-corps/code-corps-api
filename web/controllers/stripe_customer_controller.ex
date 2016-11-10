defmodule CodeCorps.StripeCustomerController do
  use CodeCorps.Web, :controller
  use JaResource

  alias CodeCorps.StripeCustomer
  alias CodeCorps.Stripe.Adapters

  plug :load_and_authorize_resource, model: StripeCustomer, only: [:show]
  plug :load_and_authorize_changeset, model: StripeCustomer, only: [:create]
  plug JaResource

  def handle_create(conn, attributes) do
    attributes
    |> CodeCorps.StripeService.create_customer
    |> handle_stripe_response(attributes, conn)
  end

  defp handle_stripe_response({:ok, stripe_response}, attributes, _conn) do
    stripe_response
    |> Adapters.StripeCustomer.to_params
    |> Adapters.StripeCustomer.add_non_stripe_attributes(attributes)
    |> create_record
  end

  defp handle_stripe_response({:error, %Stripe.APIError{}}, _, conn) do
    conn
    |> put_status(500)
    |> render(CodeCorps.ErrorView, "500.json-api")
  end

  defp create_record(attributes) do
    %StripeCustomer{}
    |> StripeCustomer.create_changeset(attributes)
    |> Repo.insert
  end
end
