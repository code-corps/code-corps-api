defmodule CodeCorpsWeb.UserView do
  @moduledoc false
  alias CodeCorps.Presenters.ImagePresenter

  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [
    :admin, :biography, :cloudinary_public_id, :email, :first_name,
    :github_avatar_url, :github_id, :github_username, :intercom_user_hash,
    :inserted_at, :last_name, :name, :photo_large_url, :photo_thumb_url,
    :sign_up_context, :state, :state_transition, :twitter, :username,
    :website, :updated_at
  ]

  has_one :slugged_route, serializer: CodeCorpsWeb.SluggedRouteView
  has_one :stripe_platform_card, serializer: CodeCorpsWeb.StripePlatformCardView
  has_one :stripe_platform_customer, serializer: CodeCorpsWeb.StripePlatformCustomerView

  has_many :categories, serializer: CodeCorpsWeb.CategoryView, identifiers: :always
  has_many :github_app_installations, serializer: CodeCorpsWeb.GithubAppInstallationView, identifiers: :always
  has_many :organizations, serializer: CodeCorpsWeb.OrganizationView, identifiers: :always
  has_many :project_users, serializer: CodeCorpsWeb.ProjectUserView, identifiers: :always
  has_many :stripe_connect_subscriptions, serializer: CodeCorpsWeb.StripeConnectSubscriptionView, identifiers: :always
  has_many :user_categories, serializer: CodeCorpsWeb.UserCategoryView, identifiers: :always
  has_many :user_roles, serializer: CodeCorpsWeb.UserRoleView, identifiers: :always
  has_many :user_skills, serializer: CodeCorpsWeb.UserSkillView, identifiers: :always

  def photo_large_url(user, _conn), do: ImagePresenter.large(user)

  def photo_thumb_url(user, _conn), do: ImagePresenter.thumbnail(user)

  @doc """
  Returns the user email or an empty string, depending on the user
  being rendered is the authenticated user, or some other user.

  Users can only see their own emails. Everyone else's are private.
  """
  def email(user, %Plug.Conn{assigns: %{current_user: current_user}}) do
    if user.id == current_user.id, do: user.email, else: ""
  end
  def email(_user, _conn), do: ""

  @intercom_secret_key Application.get_env(:code_corps, :intercom_identity_secret_key) || "RANDOM_KEY"

  def intercom_user_hash(%{id: id}, _conn) when is_number(id) do
    id |> Integer.to_string |> do_intercom_user_hash
  end
  # def intercom_user_hash(_user, _conn), do: nil

  defp do_intercom_user_hash(id_string) do
    :crypto.hmac(:sha256, @intercom_secret_key, id_string)
    |> Base.encode16
    |> String.downcase
  end

  @doc """
  Returns the user's full name when both first and last name are present.
  Returns the only user's first name or last name when the other is missing,
  otherwise returns nil.
  """
  def name(%{first_name: first_name, last_name: last_name}, _conn) do
    "#{first_name} #{last_name}" |> String.trim |> normalize_name
  end

  defp normalize_name(name) when name in ["", nil], do: nil
  defp normalize_name(name), do: name
end
