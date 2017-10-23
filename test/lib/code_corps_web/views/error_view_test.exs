defmodule CodeCorpsWeb.ErrorViewTest do
  use CodeCorpsWeb.ViewCase

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.json-api" do
    rendered_json =  render(CodeCorpsWeb.ErrorView, "404.json-api", [])

    expected_json = %{
      "errors" => [%{title: "404 Not Found", detail: "404 Not Found", status: "404"}],
        "jsonapi" => %{"version" => "1.0"}
    }
    assert rendered_json == expected_json
  end

  test "renders 500.json-api" do
    rendered_json =  render(CodeCorpsWeb.ErrorView, "500.json-api", [])

    expected_json = %{
      "errors" => [%{title: "500 Internal Server Error", detail: "500 Internal Server Error", status: "500"}],
        "jsonapi" => %{"version" => "1.0"}
    }
    assert rendered_json == expected_json
  end

  test "render any other" do
    string = render_to_string(CodeCorpsWeb.ErrorView, "505.json-api", [])

    assert String.contains? string, "Internal Server Error"
  end
end
