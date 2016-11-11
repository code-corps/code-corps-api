defmodule CodeCorps.StripeConnectAccount do
  @moduledoc """
  Represents a StripeConnectAccount stored on Code Corps.
  """

  use CodeCorps.Web, :model

  schema "stripe_connect_accounts" do
    field :business_name, :string
    field :business_url, :string
    field :charges_enabled, :boolean
    field :country, :string
    field :default_currency, :string
    field :details_submitted, :boolean
    field :display_name, :string
    field :email, :string
    field :id_from_stripe, :string, null: false
    field :managed, :boolean
    field :support_email, :string
    field :support_phone, :string
    field :support_url, :string
    field :transfers_enabled, :boolean

    field :access_code, :string, virtual: true

    belongs_to :organization, CodeCorps.Organization

    timestamps()
  end

  @insert_params [
    :business_name, :business_url, :charges_enabled, :country, :default_currency,
    :details_submitted, :email, :id_from_stripe, :managed, :organization_id,
    :support_email, :support_phone, :support_url, :transfers_enabled
  ]

  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @insert_params)
    |> validate_required([:id_from_stripe, :organization_id])
    |> assoc_constraint(:organization)
  end
end
