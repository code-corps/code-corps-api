defmodule CodeCorps.UserView do
  use CodeCorps.PreloadHelpers,
      default_preloads: [
        :slugged_route, :stripe_connect_subscriptions, :stripe_platform_card, :stripe_platform_customer,
        :organization_memberships, :user_categories, :user_roles, :user_skills
      ]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [
    :biography, :email, :first_name, :last_name, :name,
    :photo_large_url, :photo_thumb_url, :state, :state_transition, :twitter,
    :username, :website, :inserted_at, :updated_at
  ]

  has_one :slugged_route, serializer: CodeCorps.SluggedRouteView
  has_one :stripe_platform_card, serializer: CodeCorps.StripePlatformCardView
  has_one :stripe_platform_customer, serializer: CodeCorps.StripePlatformCustomerView

  has_many :stripe_connect_subscriptions, serializer: CodeCorps.StripeConnectSubscriptionView, identifiers: :always
  has_many :organization_memberships, serializer: CodeCorps.OrganizationMembershipView, identifiers: :always
  has_many :user_categories, serializer: CodeCorps.UserCategoryView, identifiers: :always
  has_many :user_roles, serializer: CodeCorps.UserRoleView, identifiers: :always
  has_many :user_skills, serializer: CodeCorps.UserSkillView, identifiers: :always

  def photo_large_url(user, _conn) do
    CodeCorps.UserPhoto.url({user.photo, user}, :large)
  end

  def photo_thumb_url(user, _conn) do
    CodeCorps.UserPhoto.url({user.photo, user}, :thumb)
  end

  @doc """
  Returns the user email or an empty string, depending on the user
  being rendered is the authenticated user, or some other user.

  Users can only see their own emails. Everyone else's are private.
  """
  def email(user, %Plug.Conn{assigns: %{current_user: current_user}}) do
    if user.id == current_user.id, do: user.email, else: ""
  end
  def email(_user, _conn), do: ""

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
