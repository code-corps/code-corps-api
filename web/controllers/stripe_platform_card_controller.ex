defmodule CodeCorps.StripePlatformCardController do
  use CodeCorps.Web, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.StripePlatformCard

  plug :load_and_authorize_resource, model: StripePlatformCard, only: [:show,], preload: [:user]
  plug :load_and_authorize_changeset, model: StripePlatformCard, only: [:create]

  plug JaResource

  def handle_create(conn, attributes) do
    attributes
    |> CodeCorps.Stripe.StripePlatformCard.create
    |> handle_create_result(conn)
  end

  defp handle_create_result({:ok, %StripePlatformCard{}} = result, conn) do
    result |> CodeCorps.Analytics.Segment.track(:created, conn)
  end
  defp handle_create_result({:error, %Stripe.APIErrorResponse{}}, conn) do
    conn
    |> put_status(500)
    |> render(CodeCorps.ErrorView, "500.json-api")
  end
  defp handle_create_result({:error, %Ecto.Changeset{} = changeset}, _conn), do: changeset
end
