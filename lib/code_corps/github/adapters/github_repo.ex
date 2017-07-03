defmodule CodeCorps.GitHub.Adapters.GithubRepo do
  def from_api(%{
    "id" => github_id,
    "name" => name,
    "owner" => %{
      "id" => github_account_id,
      "avatar_url" => github_account_avatar_url,
      "login" => github_account_login,
      "type" => github_account_type
    }
  }) do
    %{
      github_id: github_id,
      name: name,
      github_account_id: github_account_id,
      github_account_avatar_url: github_account_avatar_url,
      github_account_login: github_account_login,
      github_account_type: github_account_type
    }
  end
  def from_api(_), do: {:error, :invalid_repo_payload}
end
