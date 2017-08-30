defmodule CodeCorpsWeb.StripeConnectPlanController do
  use CodeCorpsWeb, :controller
  use JaResource

  alias CodeCorps.StripeConnectPlan
  alias CodeCorps.StripeService.StripeConnectPlanService

  plug :load_and_authorize_changeset, model: StripeConnectPlan, only: [:create]
  plug :load_and_authorize_resource, model: StripeConnectPlan, only: [:show]
  plug JaResource

  @spec model :: module
  def model, do: CodeCorps.StripeConnectPlan

  def handle_create(conn, attributes) do
    attributes
    |> StripeConnectPlanService.create
    |> handle_create_result(conn)
  end

  defp handle_create_result({:error, :project_not_ready}, conn) do
    conn
    |> put_status(422)
    |> render(CodeCorpsWeb.ErrorView, "422.json-api")
  end
  defp handle_create_result(other, _conn), do: other
end
