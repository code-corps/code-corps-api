defmodule CodeCorps.Web.Organization do
  @moduledoc """
  Represents an organization on Code Corps, e.g. "Code Corps" itself.
  """

  use CodeCorps.Web, :model

  import CodeCorps.Helpers.RandomIconColor
  import CodeCorps.Helpers.Slug
  import CodeCorps.Validators.SlugValidator

  alias CodeCorps.Web.SluggedRoute

  @type t :: %__MODULE__{}

  schema "organizations" do
    field :cloudinary_public_id
    field :default_color
    field :description, :string
    field :name, :string
    field :slug, :string
    field :approved, :boolean

    belongs_to :owner, CodeCorps.Web.User

    has_one :slugged_route, CodeCorps.Web.SluggedRoute
    has_one :stripe_connect_account, CodeCorps.Web.StripeConnectAccount

    has_many :projects, CodeCorps.Web.Project

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description, :slug, :cloudinary_public_id, :default_color])
    |> validate_required([:name, :description])
  end

  @doc """
  Builds a changeset for creating an organization.
  """
  def create_changeset(struct, params) do
    struct
    |> changeset(params)
    |> cast(params, [:owner_id])
    |> generate_slug(:name, :slug)
    |> validate_required([:description, :owner_id, :slug])
    |> assoc_constraint(:owner)
    |> validate_slug(:slug)
    |> put_slugged_route()
    |> generate_icon_color(:default_color)
  end

  defp put_slugged_route(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{slug: slug}} ->
        slugged_route_changeset = SluggedRoute.create_changeset(%SluggedRoute{}, %{slug: slug})
        put_assoc(changeset, :slugged_route, slugged_route_changeset)
      _ ->
        changeset
    end
  end
end
