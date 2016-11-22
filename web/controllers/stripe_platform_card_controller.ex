defmodule CodeCorps.StripePlatformCardController do
  use CodeCorps.Web, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.StripePlatformCard

  plug :load_and_authorize_resource, model: StripePlatformCard, only: [:show, :delete], preload: [:user]
  plug :load_and_authorize_changeset, model: StripePlatformCard, only: [:create]

  plug JaResource

  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

  def handle_create(conn, attributes) do
    attributes
    |> CodeCorps.StripeService.create_platform_card
    |> handle_create_result(conn)
  end

  defp handle_create_result({:ok, %StripePlatformCard{}} = result, conn) do
    result |> CodeCorps.Analytics.Segment.track(:created, conn)
  end

  defp handle_create_result({:error, %Stripe.APIError{}}, conn) do
    conn
    |> put_status(500)
    |> render(CodeCorps.ErrorView, "500.json-api")
  end

  defp handle_create_result({:error, %Ecto.Changeset{} = changeset}, _conn), do: changeset

  def handle_delete(conn, record) do
    record
    |> Repo.delete
    |> CodeCorps.Analytics.Segment.track(:deleted, conn)
  end
end
