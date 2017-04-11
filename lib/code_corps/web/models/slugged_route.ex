defmodule CodeCorps.Web.SluggedRoute do
  @moduledoc """
  A slugged route is used for routing slugged requests like `/joshsmith` or
  `/code-corps` to their respective owner: either a user or an organization.
  """

  use CodeCorps.Web, :model

  import CodeCorps.Helpers.Slug
  import CodeCorps.Validators.SlugValidator

  @type t :: %__MODULE__{}

  schema "slugged_routes" do
    belongs_to :organization, CodeCorps.Web.Organization
    belongs_to :user, CodeCorps.Web.User

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
