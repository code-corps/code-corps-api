defmodule CodeCorpsWeb.ErrorView do
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  def render("stripe-400.json-api", _assigns) do
    %{
      id: "INVALID_GRANT",
      title: "This authorization code has already been used. All tokens issued with this code have been revoked.",
      status: 400
    }
    |> JaSerializer.ErrorSerializer.format
  end

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
