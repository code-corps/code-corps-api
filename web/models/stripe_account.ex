defmodule CodeCorps.StripeAccount do
  @moduledoc """
  Represents a StripeAccount stored on Code Corps.
  """

  use CodeCorps.Web, :model

  schema "stripe_accounts" do
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

    belongs_to :organization, CodeCorps.Organization

    timestamps()
  end

  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id_from_stripe, :organization_id])
    |> validate_required([:id_from_stripe, :organization_id])
    |> assoc_constraint(:organization)
  end
end
