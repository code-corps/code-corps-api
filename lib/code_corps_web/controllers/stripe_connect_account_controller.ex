defmodule CodeCorpsWeb.StripeConnectAccountController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.ConnUtils
  alias CodeCorps.StripeConnectAccount
  alias CodeCorps.StripeService.StripeConnectAccountService
  alias CodeCorps.User

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id} = params) do
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         %StripeConnectAccount{} = account <- StripeConnectAccount |> Repo.get(id),
         {:ok, :authorized} <- current_user |> Policy.authorize(:show, account, params)
    do
      account = preload(account)
      conn |> render("show.json-api", data: account)
    end
  end

  @spec create(Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, params) do
    params =
      params
      |> Map.put("managed", true)
      |> Map.put("tos_acceptance_ip", conn |> ConnUtils.extract_ip)
      |> Map.put("tos_acceptance_user_agent", conn |> ConnUtils.extract_user_agent)
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %StripeConnectAccount{}, params),
         {:ok, %StripeConnectAccount{} = account} <- StripeConnectAccountService.create(params),
         account <- preload(account)
    do
      conn |> put_status(:created) |> render("show.json-api", data: account)
    end
  end

  @spec update(Conn.t, map) :: Conn.t
  def update(%Conn{} = conn, %{"id" => id} = params) do
    with %StripeConnectAccount{} = account <- StripeConnectAccount |> Repo.get(id),
         %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:update, account, params),
         {:ok, %StripeConnectAccount{} = updated_account} <- account |> StripeConnectAccountService.update(params),
         updated_account <- preload(updated_account)
    do
      conn |> render("show.json-api", data: updated_account)
    end
  end

  @preloads [:stripe_external_account]

  def preload(data) do
    Repo.preload(data, @preloads)
  end
end
