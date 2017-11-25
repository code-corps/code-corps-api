defmodule CodeCorpsWeb.StripePlatformCustomerController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.StripeService.StripePlatformCustomerService
  alias CodeCorps.{StripePlatformCustomer, User}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id} = params) do
    with %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
         %StripePlatformCustomer{} = stripe_platform_customer <- StripePlatformCustomer |> Repo.get(id),
         {:ok, :authorized} <- current_user |> Policy.authorize(:show, stripe_platform_customer, params) do
      conn |> render("show.json-api", data: stripe_platform_customer)
    end
  end

  @spec create(Plug.Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %StripePlatformCustomer{}, params),
         {:ok, %StripePlatformCustomer{} = stripe_platform_customer} <- StripePlatformCustomerService.create(params) do
      conn |> put_status(:created) |> render("show.json-api", data: stripe_platform_customer)
    end
  end
end
