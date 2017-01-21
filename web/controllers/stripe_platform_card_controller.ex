defmodule CodeCorps.StripePlatformCardController do
  use CodeCorps.Web, :controller
  use JaResource

  alias CodeCorps.StripePlatformCard
  alias CodeCorps.StripeService.StripePlatformCardService

  plug :load_and_authorize_resource, model: StripePlatformCard, only: [:show,], preload: [:user]
  plug :load_and_authorize_changeset, model: StripePlatformCard, only: [:create]

  plug JaResource

  def handle_create(conn, attributes) do
    attributes
    |> StripePlatformCardService.create
    |> handle_create_result(conn)
  end

  defp handle_create_result({:error, %Ecto.Changeset{} = changeset}, _conn), do: changeset
  defp handle_create_result({:ok, %StripePlatformCard{}} = result, conn) do
    result |> CodeCorps.Analytics.Segment.track(:created, conn)
  end
end
