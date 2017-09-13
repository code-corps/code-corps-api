defmodule CodeCorps.GithubEvent do
  use CodeCorps.Model

  @type t :: %__MODULE__{}

  schema "github_events" do
    field :action, :string
    field :github_delivery_id, :string
    field :status, :string
    field :type, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:action, :github_delivery_id, :status, :type])
    |> validate_required([:action, :github_delivery_id, :status, :type])
  end
end
