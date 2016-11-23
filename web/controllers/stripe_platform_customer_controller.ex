defmodule CodeCorps.StripePlatformCustomerController do
  use CodeCorps.Web, :controller
  use JaResource

  alias CodeCorps.StripePlatformCustomer
  alias CodeCorps.Stripe.Adapters

  plug :load_and_authorize_resource, model: StripePlatformCustomer, only: [:show]
  plug :load_and_authorize_changeset, model: StripePlatformCustomer, only: [:create]
  plug JaResource

  def handle_create(conn, attributes) do
    attributes
    |> CodeCorps.Stripe.StripePlatformCustomer.create
    |> handle_create_result(conn)
  end

  defp handle_create_result({:ok, %StripePlatformCustomer{}} = result, conn) do
    result |> CodeCorps.Analytics.Segment.track(:created, conn)
  end

  defp handle_create_result({:error, %Stripe.APIErrorResponse{}}, conn) do
    conn
    |> put_status(500)
    |> render(CodeCorps.ErrorView, "500.json-api")
  end
  defp handle_create_result({:error, %Ecto.Changeset{} = changeset}, _conn), do: changeset
end
