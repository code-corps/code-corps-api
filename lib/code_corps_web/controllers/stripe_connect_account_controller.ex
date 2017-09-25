defmodule CodeCorpsWeb.StripeConnectAccountController do
  use CodeCorpsWeb, :controller

  alias CodeCorps.ConnUtils
  alias CodeCorps.StripeConnectAccount
  alias CodeCorps.StripeService.StripeConnectAccountService
  alias CodeCorps.User

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec model :: module
  def model, do: CodeCorps.StripeConnectAccount

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id} = params) do
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         %StripeConnectAccount{} = account <- StripeConnectAccount |> Repo.get(id),
         {:ok, :authorized} <- current_user |> Policy.authorize(:show, account, params)
          do
      conn |> render("show.json-api", data: account)
    end
  end

  @spec create(Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, params) do
    params =
      params
      |> Map.put("tos_acceptance_ip", conn |> ConnUtils.extract_ip)
      |> Map.put("tos_acceptance_user_agent", conn |> ConnUtils.extract_user_agent)
      |> Map.put("managed", true)
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %StripeConnectAccount{}, params),
         {:ok, %StripeConnectAccount{} = account} <- StripeConnectAccountService.create(params) do
      conn |> put_status(:created) |> render("show.json-api", data: account)
    end
  end

  @spec update(Conn.t, map) :: Conn.t
  def update(%Conn{} = conn, %{"id" => id} = params) do
    with %StripeConnectAccount{} = account <- StripeConnectAccount |> Repo.get(id),
         %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:update, account, params),
         {:ok, %StripeConnectAccount{} = account} <- account |> StripeConnectAccount.webhook_update_changeset(params) |> Repo.update do
      conn |> render("show.json-api", data: account)
    end
  end
end
