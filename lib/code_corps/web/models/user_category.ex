defmodule CodeCorps.Web.UserCategory do
  use CodeCorps.Web, :model

  @type t :: %__MODULE__{}

  schema "user_categories" do
    belongs_to :user, CodeCorps.Web.User
    belongs_to :category, CodeCorps.Web.Category

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :category_id])
    |> validate_required([:user_id, :category_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:category)
    |> unique_constraint(:user_id, name: :index_projects_on_user_id_category_id)
  end
end
