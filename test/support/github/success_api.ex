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
  assert_received({:get, "https://api.github.com/user", body, headers, options})
  ```
  """

  import CodeCorps.GitHub.TestHelpers

  defmodule UnhandledGitHubEndpointError do
    defexception message: "You have a GitHub API endpoint that's unhandled in tests."
  end

  defmodule GitHubMockResponseError do
    defexception message: "There was a problem in building a response for your mocked GitHub API."
  end

  def request(method, url, body, headers, options) do
    send(self(), {method, url, body, headers, options})

    with {:ok, body} = get_body(method, url, body, headers, options) |> Poison.encode,
         {:ok, code} = method |> success_code()
    do
      response = %HTTPoison.Response{body: body, request_url: url, status_code: code}
      {:ok, response}
    end
  end

  defp get_body(:head, _, _, _, _), do: ""
  defp get_body(:post, "https://github.com/login/oauth/access_token", _, _, _) do
    %{"access_token" => "foo_auth_token"}
  end
  defp get_body(method, "https://api.github.com/" <> endpoint, body, headers, options) do
    get_body(method, endpoint |> String.split("/"), body, headers, options)
  end
  defp get_body(:get, ["user"], _, _, _), do: load_endpoint_fixture("user")
  defp get_body(_method, ["installation", "repositories"], _, _, _) do
    load_endpoint_fixture("installation_repositories")
  end
  defp get_body(:post, ["installations", _id, "access_tokens"], _, _, _) do
    %{
      "token" => "v1.1f699f1069f60xxx",
      "expires_at" => Timex.now() |> Timex.shift(hours: 1) |> DateTime.to_iso8601
    }
  end
  defp get_body(:get, ["repos", _owner, _repo, "issues", "comments"], _, _, _) do
    load_endpoint_fixture("issues_comments")
  end
  defp get_body(:get, ["repos", _owner, _repo, "issues", _number], _, _, _) do
    load_endpoint_fixture("issue")
  end
  defp get_body(:post, ["repos", _owner, _repo, "issues"], _, _, _) do
    load_endpoint_fixture("issue")
  end
  defp get_body(:patch, ["repos", _owner, _repo, "issues", _number], _, _, _) do
    load_endpoint_fixture("issue")
  end
  defp get_body(:post, ["repos", _owner, _repo, "issues", _number, "comments"], _, _, _) do
    load_endpoint_fixture("issue_comment")
  end
  defp get_body(:patch, ["repos", _owner, _repo, "issues", "comments", _id], _, _, _) do
    load_endpoint_fixture("issue_comment")
  end
  defp get_body(:get, ["repos", _owner, _repo, "issues"], _, _, _) do
    load_endpoint_fixture("issues")
  end
  defp get_body(:get, ["repos", _owner, _repo, "pulls"], _, _, _) do
    load_endpoint_fixture("pulls")
  end
  defp get_body(:get, ["repos", _owner, _repo, "pulls", _number], _, _, _) do
    load_endpoint_fixture("pull_request")
  end
  defp get_body(method, endpoint, _, _, _) when is_binary(endpoint) do
    raise UnhandledGitHubEndpointError, message: "You have an unhandled :#{method} request to #{endpoint}"
  end
  defp get_body(method, uri_parts, _, _, _) when is_list uri_parts do
    endpoint = uri_parts |> Enum.join("/")
    raise UnhandledGitHubEndpointError, message: "You have an unhandled API :#{method} request to #{endpoint}"
  end

  @spec success_code(atom) :: integer
  defp success_code(:get), do: {:ok, 200}
  defp success_code(:post), do: {:ok, 201}
  defp success_code(:patch), do: {:ok, 202}
  defp success_code(:put), do: {:ok, 202}
  defp success_code(:delete), do: {:ok, 204}
  defp success_code(:head), do: {:ok, 204}
  defp success_code(_), do: {:error, :unexpected_code}
end
