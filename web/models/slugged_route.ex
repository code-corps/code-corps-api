defmodule CodeCorps.SluggedRoute do
  @moduledoc """
  A slugged route is used for routing slugged requests like `/joshsmith` or
  `/code-corps` to their respective owner: either a user or an organization.
  """

  use CodeCorps.Web, :model
  import CodeCorps.ModelHelpers
  import CodeCorps.Validators.SlugValidator

  schema "slugged_routes" do
    belongs_to :organization, CodeCorps.Organization
    belongs_to :user, CodeCorps.User

    field :slug, :string

    timestamps()
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
