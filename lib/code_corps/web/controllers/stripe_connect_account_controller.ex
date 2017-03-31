defmodule CodeCorps.Web.StripeConnectAccountController do
  use CodeCorps.Web, :controller
  use JaResource

  alias CodeCorps.ConnUtils
  alias CodeCorps.Web.StripeConnectAccount
  alias CodeCorps.StripeService.StripeConnectAccountService

  plug :load_and_authorize_changeset, model: StripeConnectAccount, only: [:create]
  plug :load_and_authorize_resource, model: StripeConnectAccount, only: [:show, :update]
  plug JaResource

  def handle_create(conn, attributes) do
    attributes
    |> Map.put("tos_acceptance_ip", conn |> ConnUtils.extract_ip)
    |> Map.put("tos_acceptance_user_agent", conn |> ConnUtils.extract_user_agent)
    |> Map.put("managed", true)
    |> StripeConnectAccountService.create
  end

  def handle_update(_conn, record, attributes) do
    StripeConnectAccountService.update(record, attributes)
  end
end
