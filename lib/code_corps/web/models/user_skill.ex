defmodule CodeCorps.Web.UserSkill do
  use CodeCorps.Web, :model

  @type t :: %__MODULE__{}

  schema "user_skills" do
    belongs_to :user, CodeCorps.Web.User
    belongs_to :skill, CodeCorps.Web.Skill

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
end
