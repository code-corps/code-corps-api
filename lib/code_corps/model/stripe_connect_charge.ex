defmodule CodeCorps.StripeConnectCharge do
  use CodeCorps.Model

  @type t :: %__MODULE__{}

  schema "stripe_connect_charges" do
    field :amount, :integer
    field :amount_refunded, :integer
    field :application_id_from_stripe, :string
    field :application_fee_id_from_stripe, :string
    field :balance_transaction_id_from_stripe, :string
    field :captured, :boolean
    field :created, :integer
    field :currency, :string
    field :customer_id_from_stripe, :string
    field :description, :string
    field :failure_code, :string
    field :failure_message, :string
    field :id_from_stripe, :string, null: false
    field :invoice_id_from_stripe, :string
    field :paid, :boolean
    field :refunded, :boolean
    field :review_id_from_stripe, :string
    field :source_transfer_id_from_stripe, :string
    field :statement_descriptor, :string
    field :status, :string

    belongs_to :stripe_connect_account, CodeCorps.StripeConnectAccount
    belongs_to :stripe_connect_customer, CodeCorps.StripeConnectCustomer
    belongs_to :user, CodeCorps.User

    timestamps()
  end

  @create_attributes [
    # attributes
    :amount, :amount_refunded, :application_id_from_stripe,
    :application_fee_id_from_stripe, :balance_transaction_id_from_stripe,
    :captured, :created, :currency, :customer_id_from_stripe, :description,
    :failure_code, :failure_message, :id_from_stripe, :invoice_id_from_stripe,
    :paid, :refunded, :review_id_from_stripe, :source_transfer_id_from_stripe,
    :statement_descriptor, :status,
    # association ids
    :stripe_connect_account_id, :stripe_connect_customer_id, :user_id
  ]

  @required_attributes [
    :id_from_stripe, :stripe_connect_account_id, :stripe_connect_customer_id, :user_id
  ]

  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @create_attributes)
    |> validate_required(@required_attributes)
    |> assoc_constraint(:stripe_connect_account)
    |> assoc_constraint(:stripe_connect_customer)
    |> assoc_constraint(:user)
    |> unique_constraint(:id_from_stripe)
  end
end
