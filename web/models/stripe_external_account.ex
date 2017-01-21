defmodule CodeCorps.StripeExternalAccount do
  use CodeCorps.Web, :model

  schema "stripe_external_accounts" do
    field :id_from_stripe, :string, null: false
    field :account_id_from_stripe, :string, null: false
    field :account_holder_name, :string
    field :account_holder_type, :string
    field :bank_name, :string
    field :country, :string
    field :currency, :string
    field :default_for_currency, :boolean
    field :fingerprint, :string
    field :last4, :string
    field :routing_number, :string
    field :status, :string

    belongs_to :stripe_connect_account, CodeCorps.StripeConnectAccount

    timestamps()
  end

  @create_params [
    :id_from_stripe, :account_id_from_stripe, :account_holder_name, :account_holder_type, :bank_name,
    :country, :currency, :default_for_currency, :fingerprint, :last4, :routing_number, :status,
    :stripe_connect_account_id
  ]

  @required_create_params [:id_from_stripe, :account_id_from_stripe]

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @create_params)
    |> validate_required(@required_create_params)
    |> assoc_constraint(:stripe_connect_account)
  end
end
