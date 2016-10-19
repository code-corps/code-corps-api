defmodule CodeCorps.DonationGoal do
  @moduledoc """
  Represents one of many donation goals which can belong to a project

  ## Fields
  * amount - donation amount, in cents, needed to reach the goal
  * current - indicates if the goal is currently active
  * description - a longer, more informative description of the goal
  * title - a short, but descriptive goal title
  """

  use CodeCorps.Web, :model

  schema "donation_goals" do
    field :amount, :integer
    field :current, :boolean
    field :description, :string
    field :title, :string

    belongs_to :project, CodeCorps.Project

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:amount, :current, :description, :project_id, :title])
    |> validate_required([:amount, :current, :description, :project_id, :title])
    |> assoc_constraint(:project)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def update_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:amount, :current, :description, :title])
    |> validate_required([:amount, :current, :description, :title])
  end
end
