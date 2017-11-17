defmodule CodeCorps.GithubEvent do
  use CodeCorps.Model
  use Scrivener, page_size: 20

  alias Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "github_events" do
    field :action, :string
    field :data, :string
    field :error, :string
    field :failure_reason, :string
    field :github_delivery_id, :string
    field :payload, :map
    field :retry, :boolean, virtual: true
    field :status, :string
    field :type, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:action, :data, :github_delivery_id, :payload, :error, :status, :type])
    |> validate_required([:action, :github_delivery_id, :payload, :status, :type])
    |> validate_inclusion(:status, statuses())
  end

  def update_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:retry, :status])
    |> validate_acceptance(:retry)
    |> validate_retry()
    |> validate_inclusion(:status, statuses())
  end

  def statuses do
    ~w{unprocessed processing processed errored unsupported reprocessing}
  end

  defp validate_retry(%Changeset{changes: %{retry: true}} = changeset) do
    case changeset |> Changeset.get_field(:status) do
      "errored" -> Changeset.put_change(changeset, :status, "reprocessing")
      _ -> Changeset.add_error(changeset, :retry, "only possible when status is errored")
    end
  end
  defp validate_retry(changeset), do: changeset
end
