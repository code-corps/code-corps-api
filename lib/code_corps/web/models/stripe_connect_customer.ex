defmodule CodeCorps.Web.StripeConnectCustomer do
  use CodeCorps.Web, :model

  @type t :: %__MODULE__{}

  schema "stripe_connect_customers" do
    field :id_from_stripe, :string, null: false

    belongs_to :stripe_connect_account, CodeCorps.Web.StripeConnectAccount
    belongs_to :stripe_platform_customer, CodeCorps.Web.StripePlatformCustomer
    belongs_to :user, CodeCorps.Web.User

    timestamps()
  end

  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id_from_stripe, :stripe_connect_account_id, :stripe_platform_customer_id, :user_id])
    |> validate_required([:id_from_stripe, :stripe_connect_account_id, :stripe_platform_customer_id, :user_id])
    |> assoc_constraint(:stripe_connect_account)
    |> assoc_constraint(:stripe_platform_customer)
    |> assoc_constraint(:user)
    |> unique_constraint(:id_from_stripe)
    |> unique_constraint(:stripe_connect_account_id, name: :index_projects_on_user_id_role_id)
  end
end
