defmodule CodeCorps.StripeConnectSubscriptionController do
  use CodeCorps.Web, :controller
  use JaResource

  alias CodeCorps.StripeConnectSubscription
  alias CodeCorps.StripeService.StripeConnectSubscriptionService

  plug :load_and_authorize_resource, model: StripeConnectSubscription, only: [:show,], preload: [:user]
  plug :load_and_authorize_changeset, model: StripeConnectSubscription, only: [:create]

  plug JaResource

  def handle_create(_conn, attributes) do
    attributes |> StripeConnectSubscriptionService.find_or_create
  end
end
