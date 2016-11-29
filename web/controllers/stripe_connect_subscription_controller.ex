defmodule CodeCorps.StripeConnectSubscriptionController do
  use CodeCorps.Web, :controller
  use JaResource

  alias CodeCorps.StripeConnectSubscription
  alias CodeCorps.StripeService.StripeConnectSubscriptionService

  plug :load_and_authorize_resource, model: StripeConnectSubscription, only: [:show,], preload: [:user]
  plug :load_and_authorize_changeset, model: StripeConnectSubscription, only: [:create]

  plug JaResource

  def handle_create(conn, attributes) do
    attributes
    |> StripeConnectSubscriptionService.find_or_create
    |> handle_create_result(conn)
  end

  defp handle_create_result({:ok, %StripeConnectSubscription{}} = result, conn) do
    result |> CodeCorps.Analytics.Segment.track(:created, conn)
  end
  defp handle_create_result({:error, %Stripe.APIErrorResponse{}}, conn) do
    conn
    |> put_status(500)
    |> render(CodeCorps.ErrorView, "500.json-api")
  end
  defp handle_create_result({:error, %Ecto.Changeset{} = changeset}, _conn), do: changeset
end
