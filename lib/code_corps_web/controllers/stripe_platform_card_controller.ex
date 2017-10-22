defmodule CodeCorpsWeb.StripePlatformCardController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.StripeService.StripePlatformCardService
  alias CodeCorps.{StripePlatformCard, User}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id} = params) do
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         %StripePlatformCard{} = stripe_platform_card <- StripePlatformCard |> Repo.get(id),
         {:ok, :authorized} <- current_user |> Policy.authorize(:show, stripe_platform_card, params) do
      conn |> render("show.json-api", data: stripe_platform_card)
    end
  end

  @spec create(Plug.Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %StripePlatformCard{}, params),
         {:ok, %StripePlatformCard{} = stripe_platform_card} <- StripePlatformCardService.create(params) do
      conn |> put_status(:created) |> render("show.json-api", data: stripe_platform_card)
    end
  end
end
