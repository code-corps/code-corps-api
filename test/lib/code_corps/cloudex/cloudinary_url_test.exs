defmodule CodeCorps.Cloudex.CloudinaryUrlTest do
  use ExUnit.Case, async: true

  alias CodeCorps.Cloudex.CloudinaryUrl

  test "calls Cloudex.Url.for with correct arguments" do
    expected_args = {:test_public_id, %{test_option: nil}}
    args = CloudinaryUrl.for(:test_public_id, %{test_option: nil}, nil, nil, nil)
    assert expected_args == args
  end

  test "returns correct url if called without public_id" do
    expected_url = "#{Application.get_env(:code_corps, :asset_host)}/icons/type1_default_version1_color1.png"
    url = CloudinaryUrl.for(nil, %{}, "version1", "color1", "type1")
    assert expected_url == url
  end
end
