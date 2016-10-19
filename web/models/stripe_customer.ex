defmodule CodeCorps.StripeCustomer do
  use CodeCorps.Web, :model

  schema "stripe_customers" do
    field :created, Ecto.DateTime
    field :currency, :string
    field :delinquent, :boolean
    field :email, :string
    field :id_from_stripe, :string, null: false

    belongs_to :user, CodeCorps.User

    has_many :stripe_cards, CodeCorps.StripeCard, foreign_key: :stripe_customer_id

    timestamps()
  end

  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id_from_stripe, :user_id])
    |> validate_required([:id_from_stripe, :user_id])
    |> assoc_constraint(:user)
  end
end
