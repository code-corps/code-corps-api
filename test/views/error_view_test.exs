defmodule CodeCorps.ErrorViewTest do
  use CodeCorps.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.json-api" do
    assert render(CodeCorps.ErrorView, "404.json-api", []) ==
           %{errors: [%{status: 404, title: "404 Resource not found", id: "NOT_FOUND"}]}
  end

  test "renders 500.json-api" do
    assert render(CodeCorps.ErrorView, "500.json-api", []) ==
           %{errors: [%{status: 500, title: "500 Internal server error", id: "INTERNAL_SERVER_ERROR"}]}
  end

  test "render any other" do
    string = render_to_string(CodeCorps.ErrorView, "505.json-api", [])

    assert String.contains? string, "Internal server error"
  end
end
