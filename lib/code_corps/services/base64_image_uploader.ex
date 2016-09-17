defmodule CodeCorps.Base64ImageUploader do
  use Arc.Ecto.Schema
  import Ecto.Changeset, only: [cast: 3, validate_required: 2]

  @doc """
  Takes a changeset, a virtual origin field containing base64 image
  data, and a destination field for use with `arc_ecto` to upload
  and save an image.
  """
  def upload_image(changeset, origin_field, destination_field) do
    image_content = changeset |> Ecto.Changeset.get_change(origin_field)

    changeset
    |> do_upload_image(image_content, destination_field)
  end

  defp do_upload_image(changeset, nil, _), do: changeset
  defp do_upload_image(changeset, image_content, destination_field) do
    plug_upload =
      image_content
      |> CodeCorps.Base64Image.save_to_file()
      |> build_plug_upload

    changeset
    |> cast_attachments(%{destination_field => plug_upload}, [destination_field])
    |> validate_required([destination_field])
  end

  def build_plug_upload({path_to_image, content_type}) do
    [_, filename] = path_to_image |> String.split("/")
    %Plug.Upload{path: path_to_image, filename: filename, content_type: content_type}
  end
end
