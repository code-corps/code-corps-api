defmodule CodeCorps.StripeConnectPlanController do
  use CodeCorps.Web, :controller
  use JaResource

  alias CodeCorps.StripeConnectPlan
  alias CodeCorps.StripeService.StripeConnectPlanService

  plug :load_and_authorize_changeset, model: StripeConnectPlan, only: [:create]
  plug :load_and_authorize_resource, model: StripeConnectPlan, only: [:show]
  plug JaResource

  def handle_create(conn, attributes) do
    attributes
    |> StripeConnectPlanService.create
    |> handle_create_result(conn)
  end

  defp handle_create_result({:ok, %StripeConnectPlan{}} = result, conn) do
    result |> CodeCorps.Analytics.Segment.track(:created, conn)
  end
  defp handle_create_result({:error, :donation_goals_not_found}, conn) do
    conn
    |> put_status(422)
    |> render(CodeCorps.ErrorView, "422.json-api")
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
  defp handle_create_result({:error, _error}, conn) do
    conn
    |> put_status(500)
    |> render(CodeCorps.ErrorView, "500.json-api")
  end
end
