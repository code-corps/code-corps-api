defmodule CodeCorps.GitHub.Adapters.GithubRepoTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import CodeCorps.TestHelpers.GitHub

  alias CodeCorps.GitHub.Adapters.GithubRepo

  describe "from_api/1" do
    test "maps api payload correctly" do
      %{"repositories" => [repo]} = load_event_fixture("user_repositories")

      assert GithubRepo.from_api(repo) == %{
        github_id: repo |> get_in(["id"]),
        name: repo |> get_in(["name"]),
        github_account_id: repo |> get_in(["owner", "id"]),
        github_account_login: repo |> get_in(["owner", "login"]),
        github_account_avatar_url: repo |> get_in(["owner", "avatar_url"]),
        github_account_type: repo |> get_in(["owner", "type"]),
      }
    end
  end
end
