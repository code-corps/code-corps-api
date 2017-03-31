defmodule CodeCorps.Web.StripePlatformCustomerController do
  use CodeCorps.Web, :controller
  use JaResource

  alias CodeCorps.Web.StripePlatformCustomer
  alias CodeCorps.StripeService.StripePlatformCustomerService

  plug :load_and_authorize_resource, model: StripePlatformCustomer, only: [:show]
  plug :load_and_authorize_changeset, model: StripePlatformCustomer, only: [:create]
  plug JaResource

  def handle_create(_conn, attributes) do
    attributes |> StripePlatformCustomerService.create
  end
end
