defmodule CodeCorps.Skill do
  use CodeCorps.Model

  @type t :: %__MODULE__{}

  schema "skills" do
    field :description, :string
    field :original_row, :integer
    field :title, :string

    has_many :project_skills, CodeCorps.ProjectSkill
    has_many :projects, through: [:project_skills, :project]

    has_many :role_skills, CodeCorps.RoleSkill
    has_many :roles, through: [:role_skills, :role]

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec changeset(CodeCorps.Skill.t, map) :: Ecto.Changeset.t
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:description, :original_row, :title])
    |> validate_required([:title])
    |> unique_constraint(:title)
  end
end
