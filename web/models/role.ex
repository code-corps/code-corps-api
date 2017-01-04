defmodule CodeCorps.Role do
  @moduledoc """
  This module defines a "role" on Code Corps.

  Examples of roles are "Backend Developer" and "Front End Developer".
  """

  use CodeCorps.Web, :model

  schema "roles" do
    field :name, :string
    field :ability, :string
    field :kind, :string

    has_many :role_skills, CodeCorps.RoleSkill
    has_many :skills, through: [:role_skills, :skill]

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :ability, :kind])
    |> validate_required([:name, :ability, :kind])
    |> validate_inclusion(:kind, kinds)
  end

  defp kinds do
    ~w{ technology creative support }
  end
end
