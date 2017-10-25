defmodule CodeCorps.StripeConnectCard do
  use CodeCorps.Model

  @type t :: %__MODULE__{}

  schema "stripe_connect_cards" do
    field :id_from_stripe, :string, null: false

    belongs_to :stripe_connect_account, CodeCorps.StripeConnectAccount
    belongs_to :stripe_platform_card, CodeCorps.StripePlatformCard

    timestamps(type: :utc_datetime)
  end

  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id_from_stripe, :stripe_connect_account_id, :stripe_platform_card_id])
    |> validate_required([:id_from_stripe, :stripe_connect_account_id, :stripe_platform_card_id])
    |> assoc_constraint(:stripe_connect_account)
    |> assoc_constraint(:stripe_platform_card)
    |> unique_constraint(:id_from_stripe)
    |> unique_constraint(:stripe_connect_account_id, name: :index_projects_on_user_id_role_id)
  end
end
