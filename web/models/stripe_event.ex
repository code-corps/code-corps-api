defmodule CodeCorps.StripeEvent do
  @moduledoc """
  Represents a reference to single Stripe API Event object

  ## Fields

  * `endpoint` - "connect" or "platform"
  * `id_from_stripe` - Stripe's `id`
  * `status` - "unprocessed", "processed", or "errored"

  ## Note on `status`

  When the event is received via a webhook, it is stored as "unprocessed".
  If during processing, there is an issue, it is set to "errored". Once
  successfuly processed, it is set to "processed".

  There are cases where Stripe can send multiple webhooks for the same event,
  so when such a request is received, an event that is "errored" or "unprocessed"
  can be processed again, while a "processed" event is ignored.
  """

  use CodeCorps.Web, :model

  schema "stripe_events" do
    field :endpoint, :string, null: false
    field :id_from_stripe, :string, null: false
    field :object_id, :string
    field :object_type, :string
    field :status, :string, default: "unprocessed"
    field :type, :string, null: false
    field :user_id, :string

    timestamps()
  end

  @doc """
  Builds a changeset for storing a new event reference into the database.
  The `status` field is set to "unprocessed" by default.
  """
  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:endpoint, :id_from_stripe, :object_id, :object_type, :type, :user_id])
    |> validate_required([:endpoint, :id_from_stripe, :object_id, :object_type, :type])
    |> put_change(:status, "processing")
    |> validate_inclusion(:status, states)
    |> validate_inclusion(:endpoint, endpoints)
    |> unique_constraint(:id_from_stripe)
  end

  @doc """
  Builds a changeset for updating the status of an existing event reference.
  Accepts `:status` only and ensures it's one of "unprocessed", "processed" or
  "errored".
  """
  def update_changeset(struct, params) do
    struct
    |> cast(params, [:status])
    |> validate_required([:status])
    |> validate_inclusion(:status, states)
  end

  defp endpoints do
    ~w{ connect platform }
  end

  defp states do
    ~w{ errored processed processing unhandled unprocessed }
  end
end
