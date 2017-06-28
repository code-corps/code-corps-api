defmodule CodeCorps.GitHub.Adapters.GithubRepo do
  def from_api(%{"owner" => owner} = payload) do
    %{}
    |> Map.merge(payload |> adapt_base())
    |> Map.merge(owner |> adapt_owner())
  end

  defp adapt_base(%{"id" => id, "name" => name}) do
    %{github_id: id, name: name}
  end

  defp adapt_owner(%{"id" => id, "avatar_url" => avatar_url, "login" => login, "type" => type }) do
    %{
      github_account_id: id,
      github_account_avatar_url: avatar_url,
      github_account_login: login,
      github_account_type: type
    }
  end
end
