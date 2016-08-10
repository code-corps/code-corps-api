defmodule CodeCorps.Organization do
  @moduledoc """
  Represents an organization on Code Corps, e.g. "Code Corps" itself.
  """

  use CodeCorps.Web, :model

  alias CodeCorps.SluggedRoute

  import CodeCorps.ModelHelpers
  import CodeCorps.Validators.SlugValidator

  schema "organizations" do
    field :name, :string
    field :description, :string
    field :slug, :string

    has_one :slugged_route, SluggedRoute

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description, :slug])
    |> validate_required([:name])
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
