defmodule CodeCorps.Cloudex.CloudinaryUrlTest do
  alias CodeCorps.Cloudex.CloudinaryUrl
  use ExUnit.Case, async: true

  test "calls Cloudex.Url.for with correct arguments" do
    expected_url = "https://placehold.it/100x100"
    url = CloudinaryUrl.for(:test_public_id, %{height: 100, width: 100}, nil, nil, nil)
    assert expected_url == url
  end

  test "returns correct url if called without public_id" do
    expected_url = "#{Application.get_env(:code_corps, :asset_host)}/icons/type1_default_version1_color1.png"
    url = CloudinaryUrl.for(nil, %{}, "version1", "color1", "type1")
    assert expected_url == url
  end
end
