defmodule CodeCorps.StripeInvoice do
  @moduledoc """
  Represents a StripeInvoice stored on CodeCorps
  """

  use CodeCorps.Model

  @type t :: %__MODULE__{}

  schema "stripe_invoices" do
    field :amount_due, :integer
    field :application_fee, :integer
    field :attempt_count, :integer
    field :attempted, :boolean
    field :charge_id_from_stripe, :string, null: false
    field :closed, :boolean
    field :currency, :string
    field :customer_id_from_stripe, :string, null: false
    field :date, :integer
    field :description, :string
    field :ending_balance, :integer
    field :forgiven, :boolean
    field :id_from_stripe, :string, null: false
    field :next_payment_attempt, :integer
    field :paid, :boolean
    field :period_end, :integer
    field :period_start, :integer
    field :receipt_number, :string
    field :starting_balance, :integer
    field :statement_descriptor, :string
    field :subscription_id_from_stripe, :string, null: false
    field :subscription_proration_date, :integer
    field :subtotal, :integer
    field :tax, :integer
    field :tax_percent, :float
    field :total, :integer
    field :webhooks_delievered_at, :integer

    belongs_to :stripe_connect_subscription, CodeCorps.StripeConnectSubscription
    belongs_to :user, CodeCorps.User

    timestamps(type: :utc_datetime)
  end

  @create_attributes [
    :amount_due, :application_fee, :attempt_count, :attempted,
    :charge_id_from_stripe, :closed, :currency, :customer_id_from_stripe,
    :date, :description, :ending_balance, :forgiven, :id_from_stripe,
    :next_payment_attempt, :paid, :period_end, :period_start, :receipt_number,
    :starting_balance, :statement_descriptor, :stripe_connect_subscription_id,
    :subscription_id_from_stripe, :subscription_proration_date, :subtotal,
    :tax, :tax_percent, :total, :user_id, :webhooks_delievered_at
  ]

  @required_create_attributes [
    :charge_id_from_stripe, :customer_id_from_stripe, :id_from_stripe,
    :subscription_id_from_stripe, :stripe_connect_subscription_id, :user_id
  ]

  @doc """
  Builds a changeset used to insert a record into the database
  """
  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @create_attributes)
    |> validate_required(@required_create_attributes)
    |> unique_constraint(:id_from_stripe)
    |> assoc_constraint(:stripe_connect_subscription)
    |> assoc_constraint(:user)
  end
end
