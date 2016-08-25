defmodule CodeCorps.UserView do
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:biography, :email, :first_name, :last_name, :photo_large_url, :photo_thumb_url, :twitter, :username, :website, :inserted_at, :updated_at]

  has_one :slugged_route, serializer: CodeCorps.SluggedRouteView

  has_many :organization_memberships,
    serializer: CodeCorps.OrganizationMembershipView
  has_many :organizations, serializer: CodeCorps.OrganizationView

  has_many :user_categories, serializer: CodeCorps.UserCategoryView
  has_many :categories, serializer: CodeCorps.CategoryView

  has_many :user_roles, serializer: CodeCorps.UserRoleView
  has_many :roles, serializer: CodeCorps.RoleView

  has_many :user_skills, serializer: CodeCorps.UserSkillView
  has_many :skills, serializer: CodeCorps.SkillView

  def photo_large_url(user, _conn) do
    CodeCorps.UserPhoto.url({user.photo, user}, :large)
  end

  def photo_thumb_url(user, _conn) do
    CodeCorps.UserPhoto.url({user.photo, user}, :thumb)
  end
end
