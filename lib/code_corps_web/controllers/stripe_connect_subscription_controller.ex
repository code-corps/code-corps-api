defmodule CodeCorpsWeb.StripeConnectSubscriptionController do
  use CodeCorpsWeb, :controller

  alias CodeCorps.{StripeConnectSubscription, User}
  alias CodeCorps.StripeService.StripeConnectSubscriptionService

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id} = params) do
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         %StripeConnectSubscription{} = subscription <- StripeConnectSubscription |> Repo.get(id),
         {:ok, :authorized} <- current_user |> Policy.authorize(:show, subscription, params) do
      conn |> render("show.json-api", data: subscription)
    end
  end

  @spec create(Plug.Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %StripeConnectSubscription{}, params),
         {:ok, %StripeConnectSubscription{} = subscription} <- StripeConnectSubscriptionService.find_or_create(params) do
      conn |> put_status(:created) |> render("show.json-api", data: subscription)
    end
  end
end
