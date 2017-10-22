defmodule CodeCorpsWeb.ErrorView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  def render("404.json-api", _assigns) do
    %{
      title: "404 Not Found",
      detail: "404 Not Found",
      status: "404"
    }
    |> JaSerializer.ErrorSerializer.format
  end

  def render("500.json-api", _assigns) do
    %{
      title: "500 Internal Server Error",
      detail: "500 Internal Server Error",
      status: "500"
    }
    |> JaSerializer.ErrorSerializer.format
  end

  def render("github-error.json", %{message: message}) do
    %{
      title: "GitHub API error",
      detail: message,
      status: "500"
    }
    |> JaSerializer.ErrorSerializer.format
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.json-api", assigns
  end
end
