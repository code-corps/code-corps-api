defmodule CodeCorps.UserView do
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:username, :email, :photo_large_url, :photo_thumb_url, :inserted_at, :updated_at]

  has_one :slugged_route, serializer: CodeCorps.SluggedRouteView

  def photo_large_url(user, _conn) do
    CodeCorps.UserPhoto.url({user.photo, user}, :large)
  end

  def photo_thumb_url(user, _conn) do
    CodeCorps.UserPhoto.url({user.photo, user}, :thumb)
  end
end
