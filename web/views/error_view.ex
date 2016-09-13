defmodule CodeCorps.ErrorView do
  use CodeCorps.Web, :view

  def render("404.json-api", _assigns) do
    %{
      errors: [
        %{
          id: "NOT_FOUND",
          title: "404 Resource not found",
          status: 404,
        }
      ]
    }
  end

  def render("500.json-api", _assigns) do
    %{
      errors: [
        %{
          id: "INTERNAL_SERVER_ERROR",
          title: "500 Internal server error",
          status: 500,
        }
      ]
    }
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.json-api", assigns
  end
end
