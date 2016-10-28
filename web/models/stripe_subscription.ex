defmodule CodeCorps.StripeSubscription do
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

  use CodeCorps.Web, :model

  schema "stripe_subscriptions" do
    field :application_fee_percent, :decimal
    field :cancelled_at, Ecto.DateTime
    field :created, Ecto.DateTime
    field :current_period_end, Ecto.DateTime
    field :current_period_start, Ecto.DateTime
    field :customer_id_from_stripe, :string
    field :ended_at, Ecto.DateTime
    field :id_from_stripe, :string, null: false
    field :plan_id_from_stripe, :string, null: false
    field :quantity, :integer
    field :start, Ecto.DateTime
    field :status, :string

    belongs_to :stripe_plan, CodeCorps.StripePlan
    belongs_to :user, CodeCorps.User

    timestamps()
  end

  @permitted_params [:customer_id_from_stripe, :id_from_stripe, :plan_id_from_stripe, :stripe_plan_id, :user_id]
  @required_params [:id_from_stripe, :plan_id_from_stripe, :stripe_plan_id, :user_id]

  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @permitted_params)
    |> validate_required(@required_params)
    |> unique_constraint(:id_from_stripe)
    |> assoc_constraint(:stripe_plan)
    |> assoc_constraint(:user)
  end
end
