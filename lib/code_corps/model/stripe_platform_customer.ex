defmodule CodeCorps.StripePlatformCustomer do
  use CodeCorps.Model

  @type t :: %__MODULE__{}

  schema "stripe_platform_customers" do
    field :created, :integer
    field :currency, :string
    field :delinquent, :boolean
    field :email, :string
    field :id_from_stripe, :string, null: false

    belongs_to :user, CodeCorps.User

    has_many :stripe_connect_customers, CodeCorps.StripeConnectCustomer

    timestamps(type: :utc_datetime)
  end

  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:created, :currency, :delinquent, :id_from_stripe, :user_id])
    |> validate_required([:id_from_stripe, :user_id])
    |> assoc_constraint(:user)
  end

  def update_changeset(struct, params) do
    struct
    |> cast(params, [:email])
    |> validate_required([:email])
  end
end
