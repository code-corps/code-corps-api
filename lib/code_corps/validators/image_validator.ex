defmodule CodeCorps.Validators.ImageStats do
  @moduledoc """
  Struct for image stats needed for filtering
  """
  @magnitudes [:bytes, :kilobytes, :megabytes, :gigabytes, :terabytes]

  defstruct [
    filetype: nil,
    bytes: nil,
    width: nil,
    height: nil
  ]

  def aspect_ratio(%CodeCorps.Validators.ImageStats{width: width, height: height})
  when is_number(width) and is_number(height) do
    width / height
  end
  def aspect_ratio(_image), do: nil

  def size_in(magnitude, %CodeCorps.Validators.ImageStats{bytes: bytes})
  when magnitude in @magnitudes and is_number(bytes) do
    calculate_size_in(@magnitudes, magnitude, bytes)
  end
  def size_in(_magnitude, _image), do: nil

  defp calculate_size_in([current_magnitude | tail], desired_magnitude, count) do
    if current_magnitude == desired_magnitude do
      count
    else
      calculate_size_in(tail, desired_magnitude, count / 1024)
    end
  end
end

defmodule CodeCorps.Validators.ImageValidator do
  @moduledoc """
  Used for validating uploaded images for height, width,
  aspect ratio, and filesize.
  """
  alias CodeCorps.Validators.ImageStats

  @png_signature <<0x89, "PNG\r\n", 0x1A, "\n">>
  @jpg_start_signature 0xFFD8
  @jpg_end_signature 0xFFD9
  @gif_89_signature "GIF89a"
  @gif_87_signature "GIF87a"
  @ihdr_label "IHDR"

  def find_image_stats(image_binary) do
    image_stats = parse_image_stats(image_binary)
    if image_stats == nil do
      nil
    else
      # this is slightly smaller than the size of
      # the file when saved to disk, but close enough
      image_bytes = byte_size(image_binary)
      %ImageStats{
        bytes: image_bytes,
        height: image_stats.height,
        width: image_stats.width,
        filetype: image_stats.filetype
      }
    end
  end

  defp parse_image_stats(@png_signature <> << _length::big-integer-size(32),
    @ihdr_label,
    width::big-integer-size(32),
    height::big-integer-size(32),
    _remainder::binary >> ) do
    %{ filetype: :png,
      width: width,
      height: height }
  end

  defp parse_image_stats(<< @gif_89_signature,
    width::little-integer-size(16),
    height::little-integer-size(16),
    _remainder::binary >>) do
    %{ filetype: :gif,
      width: width,
      height: height }
  end

  defp parse_image_stats(<< @gif_87_signature,
    width::little-integer-size(16),
    height::little-integer-size(16),
    _remainder::binary >>) do
    %{ filetype: :gif,
      width: width,
      height: height }
  end

  defp parse_image_stats(<< 0xFF, 0xD8, image_binary::binary >>) do
    pieces_if_baseline = String.split(image_binary, << 0xFF, 0xC0 >>)
    pieces_if_progressive = String.split(image_binary, << 0xFF, 0xC2 >>)
    len_func = &Enum.reduce(&1, 0, fn(_val, acc) -> acc + 1 end)
    baseline_piece_count = len_func.(pieces_if_baseline)
    progressive_piece_count = len_func.(pieces_if_progressive)
    if baseline_piece_count == progressive_piece_count == 1 do
      # jpeg images will fail if neither baseline or progressive indicators are present
      nil
    else
      # otherwise, go by the more frequent indicator
      # although they should be mutually exclusive
      jpeg_pieces = if baseline_piece_count > progressive_piece_count do
        pieces_if_baseline
      else
        pieces_if_progressive
      end
      {height, width} = parse_jpeg_pieces(jpeg_pieces)
      %{ filetype: :jpg,
        width: width,
        height: height }
    end
  end
  defp parse_image_stats(_image_binary), do: nil

  # for jpegs, it's not easy to tell which size height and width refers to the base image
  # as opposed to the thumbnail(s), so we'll just go by the biggest one we find
  defp parse_jpeg_pieces([_prefix_piece | tail]), do: parse_jpeg_pieces(tail, 0, 0, 0)
  defp parse_jpeg_pieces([], height, width, _area), do: {height, width}
  defp parse_jpeg_pieces([current_piece | tail], height, width, area) do
    << _skipped_stats::size(24),
      current_height::little-integer-size(16),
      current_width::little-integer-size(16),
      _remainder::binary >> = current_piece

    current_area = current_height * current_width
    {height, width} = if current_area > area do
      {current_height, current_width}
    else
      {height, width}
    end

    parse_jpeg_pieces(tail, height, width, area)
  end
end

