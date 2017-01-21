defmodule CodeCorps.Services.Base64ImageService do
  def save_to_file("data:" <> data_string) do
    [content_type, content_string] =
      data_string
      |> String.split(";base64,")

    path_to_image =
      content_string
      |> Base.decode64!
      |> save_as_image(content_type)

    {path_to_image, content_type}
  end

  defp save_as_image(content, content_type) do
    extension = infer_extension(content_type)
    filename = random_filename(8, extension)
    path_to_image = [ensure_tmp_dir, filename] |> Path.join
    path_to_image |> File.write!(content)
    path_to_image
  end

  defp infer_extension("image/" <> extension), do: extension

  defp random_filename(length, extension), do: random_string(length) <> "." <> extension

  defp random_string(length) do
    length
    |> :crypto.strong_rand_bytes
    |> Base.url_encode64
    |> binary_part(0, length)
  end

  defp ensure_tmp_dir do
    "tmp" |> File.mkdir
    "tmp"
  end
end
