defmodule CodeCorps.GitHub.API.Gateway do
  @moduledoc ~S"""
  The gate through which all communication with the GitHub API must go through.

  The purpose of this module is to centralize the most basic GitHub API request,
  so the module can be injected into tests easily, giving full control to what
  the tested response is.
  """

  alias CodeCorps.GitHub

  @spec request(GitHub.method, String.t, GitHub.body, GitHub.headers, list) :: GitHub.response
  def request(method, url, body, headers, options) do
    HTTPoison.request(method, url, body, headers, options)
  end
end
