defmodule CodeCorps.StripePlatformCustomer do
  use CodeCorps.Web, :model

  schema "stripe_platform_customers" do
    field :created, Timex.Ecto.DateTime
    field :currency, :string
    field :delinquent, :boolean
    field :email, :string
    field :id_from_stripe, :string, null: false

    belongs_to :user, CodeCorps.User

    timestamps()
  end

  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:created, :currency, :delinquent, :id_from_stripe, :user_id])
    |> validate_required([:id_from_stripe, :user_id])
    |> assoc_constraint(:user)
  end
end
