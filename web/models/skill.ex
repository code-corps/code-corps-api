defmodule CodeCorps.Skill do
  use CodeCorps.Web, :model

  @type t :: %__MODULE__{}

  schema "skills" do
    field :title, :string
    field :description, :string
    field :original_row, :integer

    has_many :role_skills, CodeCorps.RoleSkill
    has_many :roles, through: [:role_skills, :role]

    has_many :project_skills, CodeCorps.ProjectSkill
    has_many :projects, through: [:project_skills, :project]

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :description, :original_row])
    |> validate_required([:title])
    |> unique_constraint(:title)
  end
end
