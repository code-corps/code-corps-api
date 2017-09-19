defmodule CodeCorpsWeb.StripePlatformCardController do
  use CodeCorpsWeb, :controller
  use JaResource

  alias CodeCorps.StripePlatformCard
  alias CodeCorps.StripeService.StripePlatformCardService

  plug :load_and_authorize_resource, model: StripePlatformCard, only: [:show], preload: [:user]
  plug :load_and_authorize_changeset, model: StripePlatformCard, only: [:create]

  plug JaResource

  @spec model :: module
  def model, do: CodeCorps.StripePlatformCard

  def handle_create(_conn, attributes) do
    attributes |> StripePlatformCardService.create
  end
end
