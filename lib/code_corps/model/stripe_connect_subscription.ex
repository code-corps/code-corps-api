defmodule CodeCorps.StripeConnectSubscription do
  @moduledoc """
  Represents a `Subscription` object created using the Stripe API

  ## Fields

  * `application_fee_percent` - Percentage of fee taken by Code Corps
  * `cancelled_at` - Timestamp of cancellation, provided the subscription has been cancelled
  * `created` - A timestamp, indicating when the plan was created by Stripe
  * `current_period_end` - End date of the period the subscription has been last invoiced for
  * `current_period_start` - Start date of the period the subscription was last invoiced
  * `customer_id_from_stripe` - Stripe's `customer_id`
  * `ended_at` - End date, if the subscribtion has been ended (by cancelling or switching plans)
  * `id_from_stripe` - Stripe's `id`
  * `plan_id_from_stripe` - Stripe's plan `id`
  * `quantity` - Quantity of the plan to subscribe to. For example, we have a $0.01 plan, which we subscribe in multiple quantities for.
  * `start` - Date the most recent update to this subscription started
  * `status` - trialing, active, past_due, canceled, or unpaid

  ## Note on `status`

  Subscriptioms start at `trialing` and then move on to active when trial period is over.
  When `active`, if payment fails, it will go into `past_due`.
  Once enough retry attempts failures occur,
  it goes either to `cancelled` or `unpaid` depending on settings.
  """

  use CodeCorps.Model

  @type t :: %__MODULE__{}

  schema "stripe_connect_subscriptions" do
    field :application_fee_percent, :decimal
    field :cancelled_at, :integer
    field :created, :integer
    field :current_period_end, :integer
    field :current_period_start, :integer
    field :customer_id_from_stripe, :string
    field :ended_at, :integer
    field :id_from_stripe, :string, null: false
    field :plan_id_from_stripe, :string, null: false
    field :quantity, :integer
    field :start, :integer
    field :status, :string

    belongs_to :stripe_connect_plan, CodeCorps.StripeConnectPlan
    belongs_to :user, CodeCorps.User

    has_one :project, through: [:stripe_connect_plan, :project]

    timestamps()
  end

  @permitted_params [
    :application_fee_percent, :cancelled_at, :created, :current_period_end,
    :current_period_start, :customer_id_from_stripe, :ended_at,
    :id_from_stripe, :plan_id_from_stripe, :quantity, :start, :status,
    :stripe_connect_plan_id, :user_id
  ]

  @required_params [
    :application_fee_percent, :id_from_stripe, :plan_id_from_stripe,
    :quantity, :stripe_connect_plan_id, :user_id
  ]

  @spec create_changeset(CodeCorps.StripeConnectSubscription.t, map) :: Ecto.Changeset.t
  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @permitted_params)
    |> validate_required(@required_params)
    |> unique_constraint(:id_from_stripe)
    |> assoc_constraint(:stripe_connect_plan)
    |> assoc_constraint(:user)
  end

  @update_params [:cancelled_at, :current_period_end, :current_period_start, :ended_at, :quantity, :start, :status]

  @spec webhook_update_changeset(CodeCorps.StripeConnectSubscription.t, map) :: Ecto.Changeset.t
  def webhook_update_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @update_params)
  end
end
