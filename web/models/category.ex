defmodule CodeCorps.Category do
  @moduledoc """
  Represents a category on Code Corps, e.g. "Society" and "Technology".
  """

  use CodeCorps.Web, :model

  import CodeCorps.Helpers.Slug

  @type t :: %__MODULE__{}

  schema "categories" do
    field :name, :string
    field :slug, :string
    field :description, :string

    has_many :project_categories, CodeCorps.ProjectCategory
    has_many :projects, through: [:project_categories, :project]

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description])
    |> validate_required([:name])
  end

  @doc """
  Builds a changeset for creating an category.
  """
  def create_changeset(struct, params) do
    struct
    |> changeset(params)
    |> generate_slug(:name, :slug)
    |> validate_required([:slug])
    |> unique_constraint(:slug, name: :index_categories_on_slug)
  end
end
