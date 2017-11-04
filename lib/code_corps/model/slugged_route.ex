defmodule CodeCorps.SluggedRoute do
  @moduledoc """
  A slugged route is used for routing slugged requests like `/joshsmith` or
  `/code-corps` to their respective owner: either a user or an organization.
  """

  use CodeCorps.Model

  import CodeCorps.Helpers.Slug
  import CodeCorps.Validators.SlugValidator

  @type t :: %__MODULE__{}

  schema "slugged_routes" do
    belongs_to :organization, CodeCorps.Organization
    belongs_to :user, CodeCorps.User

    field :slug, :string

    timestamps(type: :utc_datetime)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:slug])
    |> validate_required(:slug)
    |> validate_slug(:slug)
  end

  def create_changeset(struct, params) do
    struct
    |> changeset(params)
    |> generate_slug(:slug, :slug)
  end
end
