defmodule CodeCorps.ErrorViewTest do
  use CodeCorps.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.json-api" do
    string = render_to_string(CodeCorps.ErrorView, "404.json-api", [])

    assert String.contains? string, "Resource not found"
  end

  test "render 500.json-api" do
    string = render_to_string(CodeCorps.ErrorView, "500.json-api", [])

    assert String.contains? string, "Internal server error"
  end

  test "render any other" do
    string = render_to_string(CodeCorps.ErrorView, "505.json-api", [])

    assert String.contains? string, "Internal server error"
  end
end
