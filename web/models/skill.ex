defmodule CodeCorps.Skill do
  use CodeCorps.Web, :model
  import CodeCorps.Validators.SlugValidator
  import CodeCorps.ModelHelpers

  schema "skills" do
    field :title, :string
    field :description, :string
    field :original_row, :integer
    field :slug, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :description, :original_row, :slug])
    |> validate_required(:title)
    |> generate_slug(:title, :slug)
    |> validate_required(:slug)
    |> validate_slug(:slug)
    |> unique_constraint(:slug)
  end
end
