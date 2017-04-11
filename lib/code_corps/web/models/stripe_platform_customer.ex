defmodule CodeCorps.Web.StripePlatformCustomer do
  use CodeCorps.Web, :model

  @type t :: %__MODULE__{}

  schema "stripe_platform_customers" do
    field :created, :integer
    field :currency, :string
    field :delinquent, :boolean
    field :email, :string
    field :id_from_stripe, :string, null: false

    belongs_to :user, CodeCorps.Web.User

    has_many :stripe_connect_customers, CodeCorps.Web.StripeConnectCustomer

    timestamps()
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
