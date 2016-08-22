defmodule CodeCorps.Organization do
  @moduledoc """
  Represents an organization on Code Corps, e.g. "Code Corps" itself.
  """

  use Arc.Ecto.Schema
  use CodeCorps.Web, :model

  alias CodeCorps.SluggedRoute
  alias CodeCorps.Project

  import CodeCorps.Base64ImageUploader
  import CodeCorps.ModelHelpers
  import CodeCorps.Validators.SlugValidator

  schema "organizations" do
    field :base64_icon_data, :string, virtual: true
    field :description, :string
    field :icon, CodeCorps.OrganizationIcon.Type
    field :name, :string
    field :slug, :string

    has_one :slugged_route, SluggedRoute
    has_many :projects, Project

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description, :slug, :base64_icon_data])
    |> validate_required([:name])
    |> upload_image(:base64_icon_data, :icon)
  end

  @doc """
  Builds a changeset for creating an organization.
  """
  def create_changeset(struct, params) do
    struct
    |> changeset(params)
    |> generate_slug(:name, :slug)
    |> validate_required([:slug])
    |> validate_slug(:slug)
    |> put_slugged_route()
  end

  defp put_slugged_route(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{slug: slug}} ->
        slugged_route_changeset = SluggedRoute.changeset(%SluggedRoute{}, %{slug: slug})
        put_assoc(changeset, :slugged_route, slugged_route_changeset)
      _ ->
        changeset
    end
  end
end
