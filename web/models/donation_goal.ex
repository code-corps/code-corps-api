defmodule CodeCorps.DonationGoal do
  @moduledoc """
  Represents one of many donation goals which can belong to a project

  ## Fields
  * amount - donation amount, in cents, needed to reach the goal
  * current - indicates if the goal is currently active
  * description - a longer, more informative description of the goal
  """

  use CodeCorps.Web, :model

  schema "donation_goals" do
    field :amount, :integer
    field :description, :string

    belongs_to :project, CodeCorps.Project

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:amount, :description, :project_id])
    |> validate_required([:amount, :description, :project_id])
    |> assoc_constraint(:project)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def update_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:amount, :description])
    |> validate_required([:amount, :description])
  end
end
