defmodule CodeCorps.Web.StripePlatformCardController do
  use CodeCorps.Web, :controller
  use JaResource

  alias CodeCorps.Web.StripePlatformCard
  alias CodeCorps.StripeService.StripePlatformCardService

  plug :load_and_authorize_resource, model: StripePlatformCard, only: [:show,], preload: [:user]
  plug :load_and_authorize_changeset, model: StripePlatformCard, only: [:create]

  plug JaResource

  def handle_create(_conn, attributes) do
    attributes |> StripePlatformCardService.create
  end
end
