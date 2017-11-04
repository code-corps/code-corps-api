defmodule CodeCorps.Role do
  @moduledoc """
  This module defines a "role" on Code Corps.

  Examples of roles are "Backend Developer" and "Front End Developer".
  """

  use CodeCorps.Model

  @type t :: %__MODULE__{}

  schema "roles" do
    field :name, :string
    field :ability, :string
    field :kind, :string

    has_many :role_skills, CodeCorps.RoleSkill
    has_many :skills, through: [:role_skills, :skill]

    timestamps(type: :utc_datetime)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec changeset(CodeCorps.Role.t, map) :: Ecto.Changeset.t
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :ability, :kind])
    |> validate_required([:name, :ability, :kind])
    |> validate_inclusion(:kind, kinds())
  end

  defp kinds do
    ~w{ technology creative support }
  end
end
