defmodule CodeCorps.GitHub.Bypass do

  def setup(bypass) do
    Application.put_env(:code_corps, :github_oauth_url, "http://localhost:#{bypass.port}")
    Application.put_env(:code_corps, :github_base_url, "http://localhost:#{bypass.port}/")
  end

  def teardown do
    Application.delete_env(:code_corps, :github_base_url)
    Application.delete_env(:code_corps, :github_oauth_url)
  end
end
