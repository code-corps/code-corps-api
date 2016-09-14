defmodule CodeCorps.ErrorView do
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  def render("404.json-api", _assigns) do
    %{
      id: "NOT_FOUND", 
      title: "404 Resource not found", 
      status: 404
    }
    |> JaSerializer.ErrorSerializer.format
  end

  def render("500.json-api", _assigns) do
    %{
      id: "INTERNAL_SERVER_ERROR", 
      title: "500 Internal server error", 
      status: 500
    }
    |> JaSerializer.ErrorSerializer.format
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.json-api", assigns
  end
end
