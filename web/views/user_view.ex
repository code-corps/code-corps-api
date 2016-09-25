defmodule CodeCorps.UserView do
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [
    :biography, :email, :name, :first_name, :last_name,
    :photo_large_url, :photo_thumb_url, :twitter,
    :username, :website, :state,
    :inserted_at, :updated_at
  ]

  has_one :slugged_route, serializer: CodeCorps.SluggedRouteView

  has_many :organization_memberships,
    serializer: CodeCorps.OrganizationMembershipView
  has_many :organizations, serializer: CodeCorps.OrganizationView

  has_many :user_categories, serializer: CodeCorps.UserCategoryView
  has_many :user_roles, serializer: CodeCorps.UserRoleView
  has_many :user_skills, serializer: CodeCorps.UserSkillView

  def photo_large_url(user, _conn) do
    IO.inspect user
    CodeCorps.UserPhoto.url({user.photo, user}, :large)
  end

  def photo_thumb_url(user, _conn) do
    CodeCorps.UserPhoto.url({user.photo, user}, :thumb)
  end

  def name(user, _conn) do
    user.first_name <> " " <> user.last_name
  end

  @doc """
  Returns the user email or an empty string, depending on the user
  being rendered is the authenticated user, or some other user.

  Users can only see their own emails. Everyone else's are private.
  """
  def email(user, %Plug.Conn{assigns: %{current_user: current_user}}) do
    cond do
      user.id == current_user.id -> user.email
      user.id != current_user.id -> ""
    end
  end
  def email(_user, _conn), do: ""
end
