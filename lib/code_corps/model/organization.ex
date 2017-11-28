defmodule CodeCorps.Organization do
  @moduledoc """
  Represents an organization on Code Corps, e.g. "Code Corps" itself.
  """

  use CodeCorps.Model

  import CodeCorps.Helpers.RandomIconColor
  import CodeCorps.Helpers.Slug
  import CodeCorps.Validators.SlugValidator

  alias CodeCorps.SluggedRoute
  alias Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "organizations" do
    field :approved, :boolean
    field :cloudinary_public_id
    field :default_color
    field :description, :string
    field :invite_code, :string, virtual: true
    field :name, :string
    field :slug, :string

    belongs_to :owner, CodeCorps.User

    has_one :organization_invite, CodeCorps.OrganizationInvite
    has_one :slugged_route, CodeCorps.SluggedRoute
    has_one :stripe_connect_account, CodeCorps.StripeConnectAccount

    has_many :organization_github_app_installations, CodeCorps.OrganizationGithubAppInstallation
    has_many :projects, CodeCorps.Project

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:cloudinary_public_id, :description, :default_color, :name, :slug])
    |> validate_required([:description, :name])
  end

  @doc """
  Builds a changeset for creating an organization.
  """
  def create_changeset(struct, params) do
    struct
    |> changeset(params)
    |> cast(params, [:invite_code, :owner_id])
    |> maybe_generate_slug()
    |> validate_required([:cloudinary_public_id, :description, :owner_id, :slug])
    |> assoc_constraint(:owner)
    |> validate_slug(:slug)
    |> unique_constraint(:slug, name: :organizations_lower_slug_index)
    |> put_slugged_route()
    |> generate_icon_color(:default_color)
    |> put_change(:approved, false)
  end

  defp maybe_generate_slug(%Changeset{changes: %{slug: _}} = changeset) do
    changeset
  end
  defp maybe_generate_slug(%Changeset{} = changeset) do
    changeset |> generate_slug(:name, :slug)
  end

  defp put_slugged_route(%Changeset{} = changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{slug: slug}} ->
        slugged_route_changeset = SluggedRoute.create_changeset(%SluggedRoute{}, %{slug: slug})
        put_assoc(changeset, :slugged_route, slugged_route_changeset)
      _ ->
        changeset
    end
  end
end
