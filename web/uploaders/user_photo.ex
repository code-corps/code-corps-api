defmodule CodeCorps.UserPhoto do
  use Arc.Definition

  # Include ecto support (requires package arc_ecto installed):
  use Arc.Ecto.Definition

  @versions [:original, :large, :thumb]

  @acl :public_read

  # Whitelist file extensions:
  def validate({file, _}) do
    ~w(.jpg .jpeg .gif .png) |> Enum.member?(Path.extname(file.file_name))
  end

  # Large transformation
  def transform(:large, _) do
    {:convert, "-strip -thumbnail 500x500^ -gravity center -extent 500x500 -format png", :png}
  end

  # Thumbnail transformation
  def transform(:thumb, _) do
    {:convert, "-strip -thumbnail 100x100^ -gravity center -extent 100x100 -format png", :png}
  end

  # Override the persisted filenames:
  def filename(version, _) do
    version
  end

  # Override the storage directory:
  def storage_dir(_, {_, scope}) do
    "users/#{scope.id}"
  end

  # Provide a default URL if there hasn't been a file uploaded
  def default_url(version, _) do
    "#{Application.get_env(:arc, :asset_host)}/icons/user_default_#{version}.png"
  end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  # def s3_object_headers(version, {file, scope}) do
  #   [content_type: Plug.MIME.path(file.file_name)]
  # end
end
