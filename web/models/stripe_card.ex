defmodule CodeCorps.StripeCard do
  use CodeCorps.Web, :model

  schema "stripe_cards" do
    field :brand, :string
    field :customer_id_from_stripe, :string
    field :cvc_check, :string
    field :exp_month, :integer
    field :exp_year, :integer
    field :id_from_stripe, :string, null: false
    field :last4, :string
    field :name, :string

    belongs_to :user, CodeCorps.User

    timestamps()
  end

  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id_from_stripe, :user_id])
    |> validate_required([:id_from_stripe, :user_id])
    |> assoc_constraint(:user)
  end
end
