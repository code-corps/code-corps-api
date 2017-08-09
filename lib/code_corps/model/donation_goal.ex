defmodule CodeCorps.DonationGoal do
  @moduledoc """
  Represents one of many donation goals which can belong to a project

  ## Fields
  * amount - donation amount, in cents, needed to reach the goal
  * current - indicates if the goal is currently active
  * description - a longer, more informative description of the goal
  """

  use CodeCorps.Model

  @type t :: %__MODULE__{}

  schema "donation_goals" do
    field :amount, :integer
    field :current, :boolean, default: false
    field :description, :string

    belongs_to :project, CodeCorps.Project

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec create_changeset(struct, map) :: Ecto.Changeset.t
  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:amount, :description, :project_id])
    |> validate_required([:amount, :description, :project_id])
    |> validate_number(:amount, greater_than: 0)
    |> assoc_constraint(:project)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec update_changeset(struct, map) :: Ecto.Changeset.t
  def update_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:amount, :description])
    |> validate_required([:amount, :description])
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec set_current_changeset(struct, map) :: Ecto.Changeset.t
  def set_current_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:current])
    |> validate_required([:current])
    |> unique_constraint(:current, name: :donation_goals_current_unique_to_project)
  end
end
