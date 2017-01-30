defmodule CodeCorps.ErrorViewTest do
  use CodeCorps.ViewCase

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.json-api" do
    rendered_json =  render(CodeCorps.ErrorView, "404.json-api", [])

    expected_json = %{
      "errors" => [%{status: 404,  title: "404 Resource not found", id: "NOT_FOUND"}],
        "jsonapi" => %{"version" => "1.0"}
    }
    assert rendered_json == expected_json
  end

  test "renders 500.json-api" do
    rendered_json =  render(CodeCorps.ErrorView, "500.json-api", [])

    expected_json = %{
      "errors" => [%{status: 500,  title: "500 Internal server error", id: "INTERNAL_SERVER_ERROR"}],
        "jsonapi" => %{"version" => "1.0"}
    }
    assert rendered_json == expected_json
  end

  test "render any other" do
    string = render_to_string(CodeCorps.ErrorView, "505.json-api", [])

    assert String.contains? string, "Internal server error"
  end
end
