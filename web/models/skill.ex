defmodule CodeCorps.Skill do
  use CodeCorps.Web, :model
  import CodeCorps.Validators.SlugValidator
  alias Inflex

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
    |> update_slug()
    |> validate_required([:title, :slug])
    |> validate_slug(:slug)
    |> unique_constraint(:slug)
  end

  def update_slug(changeset) do
    case changeset do
      %Ecto.Changeset{changes: %{title: title}} ->
        slug = Inflex.parameterize(title)
        put_change(changeset, :slug, slug)
      _ ->
        changeset
    end

  end
end
