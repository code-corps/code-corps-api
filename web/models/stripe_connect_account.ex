defmodule CodeCorps.StripeConnectAccount do
  @moduledoc """
  Represents a StripeConnectAccount stored on Code Corps.
  """

  use CodeCorps.Web, :model

  schema "stripe_connect_accounts" do
    # these might not be needed by managed accounts,
    # but we have them defined at DB level

    field :business_url, :string
    field :default_currency, :string
    field :details_submitted, :boolean
    field :display_name, :string
    field :support_email, :string
    field :support_phone, :string
    field :support_url, :string

    # this was needed for connect
    field :access_code, :string, virtual: true

    # these fields are filled out and sent by the client

    field :address1, :string, virtual: true
    field :address2, :string, virtual: true
    field :business_ein, :string, virtual: true
    field :business_name, :string
    field :business_type, :string, virtual: true
    field :city, :string, virtual: true
    field :country, :string
    field :dob_day, :integer, virtual: true
    field :dob_month, :integer, virtual: true
    field :dob_year, :integer, virtual: true
    field :email, :string
    field :first_name, :string, virtual: true
    field :last_name, :string, virtual: true
    field :recipient_type, :string, virtual: true
    field :ssn_last4, :string, virtual: true
    field :state, :string, virtual: true
    field :zip, :string, virtual: true

    belongs_to :organization, CodeCorps.Organization

    # these fields are set automatically
    field :managed, :boolean

    # these fields are set from stripe
    field :id_from_stripe, :string, null: false
    field :charges_enabled, :boolean
    field :transfers_enabled, :boolean
    timestamps()
  end

  @managed_create_fields [
    :address1, :address2, :business_ein, :business_name, :business_type,
    :city, :country, :dob_day, :dob_month, :dob_year, :email,
    :first_name, :last_name, :recipient_type, :ssn_last4,
    :state, :zip, :organization_id,
    :managed, :id_from_stripe, :charges_enabled, :transfers_enabled
  ]

  def managed_create_changeset(struct, params) do
    struct
    |> cast(params, @managed_create_fields)
    |> validate_required(@managed_create_fields)
    |> assoc_constraint(:organization)
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

  @webhook_update_params [
    :business_name, :business_url, :charges_enabled, :country,
    :default_currency, :details_submitted, :email, :managed, :support_email,
    :support_phone, :support_url, :transfers_enabled
  ]

  def webhook_update_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @webhook_update_params)
  end
end
