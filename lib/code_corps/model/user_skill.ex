defmodule CodeCorps.UserSkill do
  use CodeCorps.Model

  @type t :: %__MODULE__{}

  schema "user_skills" do
    belongs_to :user, CodeCorps.User
    belongs_to :skill, CodeCorps.Skill

    timestamps(type: :utc_datetime)
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
