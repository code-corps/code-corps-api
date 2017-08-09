defmodule CodeCorpsWeb.StripePlatformCustomerController do
  use CodeCorpsWeb, :controller
  use JaResource

  alias CodeCorps.StripePlatformCustomer
  alias CodeCorps.StripeService.StripePlatformCustomerService

  plug :load_and_authorize_resource, model: StripePlatformCustomer, only: [:show]
  plug :load_and_authorize_changeset, model: StripePlatformCustomer, only: [:create]
  plug JaResource

  @spec model :: module
  def model, do: CodeCorps.StripePlatformCustomer

  def handle_create(_conn, attributes) do
    attributes |> StripePlatformCustomerService.create
  end
end
