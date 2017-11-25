defmodule CodeCorps.Cloudex.UploaderTest do
  alias CodeCorps.Cloudex.Uploader
  use ExUnit.Case, async: true

  test "returns the public_id" do
    {:ok, %Cloudex.UploadedImage{public_id: public_id}} =
      "https://placehold.it/500x500"
      |> Uploader.upload

    assert public_id
  end
end
