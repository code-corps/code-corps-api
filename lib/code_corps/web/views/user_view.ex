defmodule CodeCorps.Web.UserView do
  alias CodeCorps.Presenters.ImagePresenter

  use CodeCorps.PreloadHelpers,
      default_preloads: [
        :project_users, :slugged_route, :stripe_connect_subscriptions,
        :stripe_platform_card, :stripe_platform_customer,
        :user_categories, :user_roles, :user_skills
      ]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [
    :biography, :cloudinary_public_id, :email, :first_name, :last_name, :name,
    :photo_large_url, :photo_thumb_url, :sign_up_context, :state,
    :state_transition, :twitter, :username, :website, :inserted_at, :updated_at
  ]

  has_one :slugged_route, serializer: CodeCorps.Web.SluggedRouteView
  has_one :stripe_platform_card, serializer: CodeCorps.Web.StripePlatformCardView
  has_one :stripe_platform_customer, serializer: CodeCorps.Web.StripePlatformCustomerView

  has_many :project_users, serializer: CodeCorps.Web.ProjectUserView, identifiers: :always
  has_many :stripe_connect_subscriptions, serializer: CodeCorps.Web.StripeConnectSubscriptionView, identifiers: :always
  has_many :user_categories, serializer: CodeCorps.Web.UserCategoryView, identifiers: :always
  has_many :user_roles, serializer: CodeCorps.Web.UserRoleView, identifiers: :always
  has_many :user_skills, serializer: CodeCorps.Web.UserSkillView, identifiers: :always

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
