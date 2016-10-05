defmodule CodeCorps.UserSkill do
  use CodeCorps.Web, :model

  import CodeCorps.ModelHelpers

  schema "user_skills" do
    belongs_to :user, CodeCorps.User
    belongs_to :skill, CodeCorps.Skill

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :skill_id])
    |> validate_required([:user_id, :skill_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:skill)
    |> unique_constraint(:user_id, name: :index_projects_on_user_id_skill_id)
  end

  def index_filters(query, params) do
    query |> id_filter(params)
  end
end
