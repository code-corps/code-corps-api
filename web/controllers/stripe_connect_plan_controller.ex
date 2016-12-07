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

  defp handle_create_result({:error, %Ecto.Changeset{} = changeset}, _conn), do: changeset
  defp handle_create_result({:error, :project_not_ready}, conn) do
    conn
    |> put_status(422)
    |> render(CodeCorps.ErrorView, "422.json-api")
  end
  defp handle_create_result({:ok, %StripeConnectPlan{}} = result, conn) do
    result |> CodeCorps.Analytics.Segment.track(:created, conn)
  end
end
