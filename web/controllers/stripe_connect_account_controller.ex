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

  def handle_update(conn, record, %{"external_account" => external_account}) do
    with {:ok, _} = result <- StripeConnectAccountService.add_external_account(record, external_account)
    do
      CodeCorps.Analytics.Segment.track(result, :created, conn)
    else
      {:error, %Ecto.Changeset{} = changeset} -> changeset
    end
  end

  def handle_update(conn, _record, _attributes), do: conn |> unauthorized

  defp unauthorized(conn) do
    conn
    |> Plug.Conn.assign(:authorized, false)
    |> CodeCorps.AuthenticationHelpers.handle_unauthorized
  end
end
