defmodule CodeCorps.GitHub.SuccessAPI do
  @moduledoc ~S"""
  A mocked github API layer which returns a default successful response for all
  GitHub API requests.

  All tests in the test environment use this module as a mock for GitHub API
  requests by default.

  If certain tests explicitly depend on the data returned by GitHub, they can be
  mocked individually using the `CodeCorps.GitHub.TestHelpers.with_mock_api`
  macro.

  As support for new GitHub endpoints is added, defaults for those endpoints
  should be added here.

  To assert a request has been made to GitHub as a result as an action, the
  `assert_received` test helper can be used:

  ```
  assert_received({:get, "https://api.github.com/user", headers, body, options})
  ```
  """

  import CodeCorps.GitHub.TestHelpers

  defmodule UnhandledGitHubEndpointError do
    defexception message: "You have a GitHub API endpoint that's unhandled in tests."
  end

  def request(method, url, headers, body, options) do
    send(self(), {method, url, headers, body, options})

    {:ok, mock_response(method, url, headers, body, options)}
  end

  defp mock_response(:post, "https://github.com/login/oauth/access_token", _, _, _) do
    %{"access_token" => "foo_auth_token"}
  end
  defp mock_response(method, "https://api.github.com/" <> endpoint, headers, body, options) do
    mock_response(method, endpoint |> String.split("/"), headers, body, options)
  end
  defp mock_response(:get, ["user"], _, _, _) do
    %{
      "avatar_url" => "foo_url",
      "email" => "foo_email",
      "id" => 123,
      "login" => "foo_login"
    }
  end
  defp mock_response(_method, ["installation", "repositories"], _, _, _) do
    load_endpoint_fixture("installation_repositories")
  end
  defp mock_response(:post, ["installations", _id, "access_tokens"], _, _, _) do
    %{
      "token" => "v1.1f699f1069f60xxx",
      "expires_at" => Timex.now() |> Timex.shift(hours: 1) |> DateTime.to_iso8601
    }
  end
  defp mock_response(:post, ["repos", _owner, _repo, "issues"], _, _, _) do
    load_endpoint_fixture("issue")
  end
  defp mock_response(:patch, ["repos", _owner, _repo, "issues", _number], _, _, _) do
    load_endpoint_fixture("issue")
  end
  defp mock_response(:post, ["repos", _owner, _repo, "issues", _number, "comments"], _, _, _) do
    load_endpoint_fixture("issue_comment")
  end
  defp mock_response(:patch, ["repos", _owner, _repo, "issues", _number, "comments", _id], _, _, _) do
    load_endpoint_fixture("issue_comment")
  end
  defp mock_response(method, endpoint, _, _, _) when is_binary(endpoint) do
    raise UnhandledGitHubEndpointError, message: "You have an unhandled :#{method} request to #{endpoint}"
  end
  defp mock_response(method, uri_parts, _, _, _) when is_list uri_parts do
    endpoint = uri_parts |> Enum.join("/")
    raise UnhandledGitHubEndpointError, message: "You have an unhandled API :#{method} request to #{endpoint}"
  end
end
