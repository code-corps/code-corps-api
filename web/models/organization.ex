defmodule CodeCorps.Organization do
  @moduledoc """
  Represents an organization on Code Corps, e.g. "Code Corps" itself.
  """

  use CodeCorps.Web, :model
  import CodeCorps.Helpers.RandomIconColor
  import CodeCorps.Helpers.Slug
  import CodeCorps.Validators.SlugValidator
  alias CodeCorps.SluggedRoute

  schema "organizations" do
    field :cloudinary_public_id
    field :default_color
    field :description, :string
    field :name, :string
    field :slug, :string
    field :approved, :boolean

    has_one :slugged_route, CodeCorps.SluggedRoute
    has_one :stripe_connect_account, CodeCorps.StripeConnectAccount

    has_many :projects, CodeCorps.Project

    has_many :organization_memberships, CodeCorps.OrganizationMembership
    has_many :members, through: [:organization_memberships, :member]

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
    |> generate_slug(:name, :slug)
    |> validate_required([:slug, :description])
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
