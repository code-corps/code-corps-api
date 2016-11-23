defmodule CodeCorps.StripeConnectAccountController do
  use CodeCorps.Web, :controller
  use JaResource

  alias CodeCorps.StripeConnectAccount

  plug :load_and_authorize_changeset, model: StripeConnectAccount, only: [:create]
  plug :load_and_authorize_resource, model: StripeConnectAccount, only: [:show]
  plug JaResource

  def handle_create(conn, attributes) do
    attributes
    |> CodeCorps.Stripe.StripeConnectAccount.create
    |> handle_create_result(conn)
  end

  defp handle_create_result({:ok, %StripeConnectAccount{}} = result, conn) do
    result |> CodeCorps.Analytics.Segment.track(:created, conn)
  end
  defp handle_create_result({:error, %Stripe.APIErrorResponse{}}, conn) do
    conn
    |> put_status(500)
    |> render(CodeCorps.ErrorView, "500.json-api")
  end
  defp handle_create_result({:error, %Stripe.OAuthAPIErrorResponse{}}, conn) do
    conn
    |> put_status(400)
    |> render(CodeCorps.ErrorView, "stripe-400.json-api")
  end
  defp handle_create_result({:error, %Ecto.Changeset{} = changeset}, _conn), do: changeset
end
