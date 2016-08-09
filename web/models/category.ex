defmodule CodeCorps.Category do
    @moduledoc """
    Represents an category on Code Corps, e.g. "Society" and "Technology".
    """

  use CodeCorps.Web, :model

  import CodeCorps.Validators.SlugValidator

  schema "categories" do
    field :name, :string
    field :slug, :string
    field :description, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :slug, :description])
    |> validate_required([:name, :slug, :description])
    |> validate_slug(:slug)
  end
end
