defmodule CodeCorps.Presenters.ImagePresenter do
  alias CodeCorps.Web.{Project, User}
  alias CodeCorps.Cloudex.CloudinaryUrl

  @logo_options %{crop: "fill", height: 500, width: 500}

  def large(%Project{} = project), do: do_large(project, "project")
  def large(%User{} = user), do: do_large(user, "user")

  defp do_large(%{cloudinary_public_id: cloudinary_id, default_color: color}, type),
    do: cloudinary_image(cloudinary_id, @logo_options, "large", color, type)

  @thumb_options %{crop: "fill", height: 100, width: 100}

  def thumbnail(%Project{} = project), do: do_thumbnail(project, "project")
  def thumbnail(%User{} = user), do: do_thumbnail(user, "user")

  defp do_thumbnail(%{cloudinary_public_id: cloudinary_id, default_color: color}, type),
    do: cloudinary_image(cloudinary_id, @thumb_options, "thumb", color, type)

  defp cloudinary_image(id, options, category, color, type),
    do: CloudinaryUrl.for(id, options, category, color, type)
end
