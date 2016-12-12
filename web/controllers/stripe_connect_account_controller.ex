defmodule CodeCorps.StripeConnectAccountController do
  use CodeCorps.Web, :controller
  use JaResource

  alias CodeCorps.StripeConnectAccount
  alias CodeCorps.StripeService.StripeConnectAccountService

  plug :load_and_authorize_changeset, model: StripeConnectAccount, only: [:create]
  plug :load_and_authorize_resource, model: StripeConnectAccount, only: [:show]
  plug JaResource

  def handle_create(conn, attributes) do
    attributes
    |> StripeConnectAccountService.create
    |> handle_create_result(conn)
  end

  defp handle_create_result({:error, %Ecto.Changeset{} = changeset}, _conn), do: changeset
  defp handle_create_result({:ok, %StripeConnectAccount{}} = result, conn) do
    result |> CodeCorps.Analytics.Segment.track(:created, conn)
  end
end
