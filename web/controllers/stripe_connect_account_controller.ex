defmodule CodeCorps.StripeConnectAccountController do
  use CodeCorps.Web, :controller
  use JaResource

  alias CodeCorps.ConnUtils
  alias CodeCorps.StripeConnectAccount
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
    |> handle_create_result(conn)
  end

  defp handle_create_result({:error, %Ecto.Changeset{} = changeset}, _conn), do: changeset
  defp handle_create_result({:ok, %StripeConnectAccount{}} = result, conn) do
    result |> CodeCorps.Analytics.Segment.track(:created, conn)
  end

  def handle_update(conn, record, attributes) do
    with {:ok, _} = result <- StripeConnectAccountService.update(record, attributes)
    do
      CodeCorps.Analytics.Segment.track(result, :created, conn)
    else
      {:error, %Ecto.Changeset{} = changeset} -> changeset
    end
  end
end
