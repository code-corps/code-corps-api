defmodule CloudexTest do
  @moduledoc """
  Testing stub for `Cloudex`,

  Each function should have the same signature as `Cloudex`.
  """

  defmodule Url do
    def for(_public_id, %{height: height, width: width}) do
      "https://placehold.it/#{width}x#{height}"
    end
    def for(_public_id, _options) do
      "https://placehold.it/500x500"
    end
  end

  @spec upload(String.t) :: {:ok, %Cloudex.UploadedImage{}}
  def upload(_url) do
    {:ok, %Cloudex.UploadedImage{public_id: fake_cloudinary_id()}}
  end

  defp fake_cloudinary_id do
    :crypto.strong_rand_bytes(5)
    |> Base.encode64
  end
end
