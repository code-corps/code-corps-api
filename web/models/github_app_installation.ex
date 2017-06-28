defmodule CodeCorps.GithubAppInstallation do
  use CodeCorps.Web, :model

  schema "github_app_installations" do
    field :access_token, :string
    field :access_token_expires_at, :utc_datetime
    field :github_id, :integer
    field :installed, :boolean
    field :state, :string

    belongs_to :project, CodeCorps.Project # The originating project
    belongs_to :user, CodeCorps.User

    has_many :github_repos, CodeCorps.GithubRepo

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def create_changeset(struct, params \\ %{}) do
    struct
    |> changeset(params)
  end

  def update_changeset(struct, params \\ %{}) do
    struct
    |> changeset(params)
  end

  def access_token_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:access_token, :access_token_expires_at])
    |> validate_required([:access_token, :access_token_expires_at])
  end

  defp changeset(struct, params) do
    struct
    |> cast(params, [:github_id, :project_id, :state, :user_id])
    |> validate_required([:project_id, :user_id])
    |> validate_inclusion(:state, states())
    |> unique_constraint(:github_id, name: :github_app_installations_github_id_index)
    |> apply_state_transition(struct)
    |> assoc_constraint(:project)
    |> assoc_constraint(:user)
  end

  def apply_state_transition(changeset, %{state: current_state}) do
    changed_state = get_field(changeset, :state)
    next_state =
      current_state
      |> CodeCorps.Transition.GithubAppInstallationState.next(changed_state)
    case next_state do
      nil -> changeset
      {:ok, next_state} -> cast(changeset, %{state: next_state}, [:state])
      {:error, reason} -> add_error(changeset, :state, reason)
    end
  end

  defp states do
    ~w{ initiated_on_code_corps initiated_on_github processed processing unmatched_user }
  end
end
