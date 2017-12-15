defmodule CodeCorps.User do
  @moduledoc """
  This module defines a user of the Code Corps app.
  """

  use CodeCorps.Model

  import CodeCorps.Helpers.RandomIconColor
  import CodeCorps.Helpers.URL, only: [prefix_url: 2]
  import CodeCorps.Validators.SlugValidator

  alias CodeCorps.SluggedRoute
  alias Comeonin.Bcrypt
  alias Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "users" do
    field :admin, :boolean
    field :biography, :string
    field :cloudinary_public_id
    field :default_color
    field :encrypted_password, :string
    field :email, :string
    field :first_name, :string
    field :github_auth_token, :string
    field :github_avatar_url, :string
    field :github_email, :string
    field :github_id, :integer
    field :github_id_was, :integer
    field :github_username, :string
    field :last_name, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :sign_up_context, :string, default: "default"
    field :state, :string, default: "signed_up"
    field :state_transition, :string, virtual: true
    field :twitter, :string
    field :type, :string, default: "user"
    field :username, :string
    field :website, :string

    has_one :github_app_installation, CodeCorps.GithubAppInstallation
    has_one :slugged_route, SluggedRoute

    has_many :github_app_installations, CodeCorps.GithubAppInstallation
    has_many :organizations, CodeCorps.Organization, foreign_key: :owner_id
    has_many :project_users, CodeCorps.ProjectUser
    has_many :stripe_connect_customers, CodeCorps.StripeConnectCustomer
    has_many :stripe_connect_subscriptions, CodeCorps.StripeConnectSubscription
    has_one :stripe_platform_card, CodeCorps.StripePlatformCard
    has_one :stripe_platform_customer, CodeCorps.StripePlatformCustomer
    has_many :user_categories, CodeCorps.UserCategory
    has_many :categories, through: [:user_categories, :category]
    has_many :user_roles, CodeCorps.UserRole
    has_many :roles, through: [:user_roles, :role]
    has_many :user_skills, CodeCorps.UserSkill
    has_many :skills, through: [:user_skills, :skill]

    belongs_to :github_user, CodeCorps.GithubUser

    timestamps()
  end

  @doc """
  Returns full name of the given user.
  """
  def full_name(%__MODULE__{first_name: first_name, last_name: last_name}) do
    [first_name, last_name]
    |> Enum.map_join(" ", &to_string/1)
    |> String.trim()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :default_color])
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/)
  end

  @doc """
  Builds a changeset for registering the user.
  """
  def registration_changeset(struct, params) do
    struct
    |> changeset(params)
    |> cast(params, [:password, :sign_up_context, :username])
    |> validate_required([:password, :username])
    |> validate_length(:password, min: 6)
    |> validate_length(:username, min: 1, max: 39)
    |> validate_inclusion(:sign_up_context, ["default", "donation"])
    |> validate_slug(:username)
    |> unique_constraint(:username, name: :users_lower_username_index)
    |> unique_constraint(:email)
    |> put_change(:type, "user")
    |> put_pass_hash()
    |> put_slugged_route()
    |> generate_icon_color(:default_color)
  end

  def update_changeset(struct, params) do
    struct
    |> changeset(params)
    |> cast(params, [:biography, :cloudinary_public_id, :first_name, :last_name, :state_transition, :twitter, :website])
    |> prefix_url(:website)
    |> validate_format(:website, CodeCorps.Helpers.URL.valid_format())
    |> validate_format(:twitter, ~r/\A[a-zA-Z0-9_]{1,15}\z/)
    |> apply_state_transition(struct)
  end

  def reset_password_changeset(struct, params) do
    struct
    |> cast(params, [:password, :password_confirmation])
    |> validate_confirmation(:password, message: "passwords do not match")
    |> put_pass_hash
  end

  def apply_state_transition(changeset, %{state: current_state}) do
    state_transition = get_field(changeset, :state_transition)
    next_state = CodeCorps.Transition.UserState.next(current_state, state_transition)
    case next_state do
      nil -> changeset
      {:ok, next_state} -> cast(changeset, %{state: next_state}, [:state])
      {:error, reason} -> add_error(changeset, :state_transition, reason)
    end
  end

  def check_email_availability(email) do
    %{}
    |> check_email_valid(email)
    |> check_used(:email, email)
  end

  def check_username_availability(username) do
    %{}
    |> check_username_valid(username)
    |> check_used(:username, username)
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :encrypted_password, Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end

  defp put_slugged_route(changeset) do
    case changeset do
      %Changeset{valid?: true, changes: %{username: username}} ->
        slugged_route_changeset = SluggedRoute.create_changeset(%SluggedRoute{}, %{slug: username})
        put_assoc(changeset, :slugged_route, slugged_route_changeset)
      _ ->
        changeset
    end
  end

  defp check_email_valid(struct, email) do
    struct
    |> Map.put(:valid, String.match?(email, ~r/@/))
  end

  defp check_username_valid(struct, username) do
    valid =
      username
      |> String.length
      |> in_range?(1, 39)

    struct
    |> Map.put(:valid, valid)
  end

  defp in_range?(number, min, max), do: number in min..max

  defp check_used(struct, column, value) do
    available =
      CodeCorps.User
      |> where([u], field(u, ^column) == ^value)
      |> CodeCorps.Repo.all
      |> Enum.empty?

    struct
    |> Map.put(:available, available)
  end
end
