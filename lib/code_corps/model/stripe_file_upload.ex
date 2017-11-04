defmodule CodeCorps.StripeFileUpload do
  use CodeCorps.Model

  @type t :: %__MODULE__{}

  schema "stripe_file_uploads" do
    field :created, :integer
    field :id_from_stripe, :string, null: false
    field :purpose, :string
    field :size, :integer
    field :type, :string
    field :url, :string

    belongs_to :stripe_connect_account, CodeCorps.StripeConnectAccount

    timestamps(type: :utc_datetime)
  end

  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:created, :id_from_stripe, :purpose, :size, :type, :url, :stripe_connect_account_id])
    |> validate_required([:id_from_stripe])
    |> assoc_constraint(:stripe_connect_account)
  end
end
