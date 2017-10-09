defmodule CodeCorpsWeb.StripeConnectPlanController do
  use CodeCorpsWeb, :controller

  alias CodeCorps.{StripeConnectPlan, User}
  alias CodeCorps.StripeService.StripeConnectPlanService

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id} = params) do
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         %StripeConnectPlan{} = stripe_platform_plan <- StripeConnectPlan |> Repo.get(id),
         {:ok, :authorized} <- current_user |> Policy.authorize(:show, stripe_platform_plan, params) do
      conn |> render("show.json-api", data: stripe_platform_plan)
    end
  end

  @spec create(Plug.Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %StripeConnectPlan{}, params),
         {:ok, %StripeConnectPlan{} = stripe_platform_plan} <- StripeConnectPlanService.create(params) |> handle_create_result(conn) do
      conn |> put_status(:created) |> render("show.json-api", data: stripe_platform_plan)
    end
  end

  defp handle_create_result({:error, :project_not_ready}, conn) do
    conn
    |> put_status(422)
    |> render(CodeCorpsWeb.ErrorView, "422.json-api")
  end
  defp handle_create_result(other, _conn), do: other
end
