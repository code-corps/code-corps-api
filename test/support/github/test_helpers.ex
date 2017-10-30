defmodule CodeCorps.GitHub.TestHelpers do
  import CodeCorps.Factories

  @spec load_endpoint_fixture(String.t) :: map
  def load_endpoint_fixture(id) do
    "./test/fixtures/github/endpoints/#{id}.json" |> File.read! |> Poison.decode!
  end

  @spec load_event_fixture(String.t) :: map
  def load_event_fixture(id) do
    "./test/fixtures/github/events/#{id}.json" |> File.read! |> Poison.decode!
  end

  @spec setup_coderly_project_repo :: %CodeCorps.ProjectGithubRepo{}
  def setup_coderly_project_repo do
    # Data is from the coderly/github-app-testing repository
    #
    # Uses:
    #
    # - the real repository owner
    # - the real repository name
    # - the real GitHub user id of the repository owner
    # - the real GitHub App id
    # - the real GitHub repo id
    setup_real_project_repo("coderly", "github-app-testing", 321667, 63365, 108674236)
  end

  @spec setup_real_project_repo(String.t, String.t, Integer.t, Integer.t, Integer.t) :: %CodeCorps.ProjectGithubRepo{}
  def setup_real_project_repo(repo_owner, repo_name, repo_owner_id, app_github_id, repo_github_id) do
    # Create the user
    #
    # Simulates:
    #
    # - user (the repo owner) connecting their account with GitHub
    github_user = insert(:github_user, email: nil, github_id: repo_owner_id, avatar_url: "https://avatars3.githubusercontent.com/u/#{repo_owner_id}?v=4", type: "User", username: repo_owner)
    user = insert(:user, github_avatar_url: "https://avatars3.githubusercontent.com/u/#{repo_owner_id}?v=4", github_id: repo_owner_id, github_user: github_user, github_username: repo_owner, type: "user")

    # Create the organization and project for that organization
    #
    # Simulates:
    #
    # - user creating an organization
    # - organization creating a project
    # - project being bootstrapped with an inbox task list to receive new tasks
    organization = insert(:organization, owner: user)
    project = insert(:project, organization: organization)
    insert(:task_list, project: project, inbox: true)

    # Create the GitHub App installation on the organization
    #
    # Simulates:
    #
    # - installation webhook
    # - user installing the organization
    github_app_installation = insert(:github_app_installation, github_account_login: repo_owner, github_id: app_github_id, project: project, user: user)
    insert(:organization_github_app_installation, github_app_installation: github_app_installation, organization: organization)

    # Create the repo on the installation
    #
    # Simulates:
    #
    # - installation or installation_repositories webhook
    # - user connecting the repository to the project
    github_repo = insert(:github_repo, github_app_installation: github_app_installation, name: repo_name, github_account_id: repo_owner_id, github_account_avatar_url: "https://avatars3.githubusercontent.com/u/#{repo_owner_id}?v=4", github_account_type: "User", github_id: repo_github_id)
    project_github_repo = insert(:project_github_repo, github_repo: github_repo, project: project)

    # Return the %CodeCorps.ProjectGithubRepo{} record
    project_github_repo
  end

  @doc ~S"""
  Allows setting a mock Github API module for usage in specific tests
  To use it, define a module containing the methods expected to be called, then
  pass in the block of code expected to call it into the macro:
  ```
  defmodule MyApiModule do
    def some_function, do: "foo"
  end
  with_mock_api(MyApiModule) do
    execute_code_calling_api
  end
  ```
  """
  @spec with_mock_api(module, do: function) :: any
  defmacro with_mock_api(mock_module, do: block) do
    quote do
      old_mock = Application.get_env(:code_corps, :github)
      Application.put_env(:code_corps, :github, unquote(mock_module))

      unquote(block)

      Application.put_env(:code_corps, :github, old_mock)
    end
  end

  @spec with_real_api(do: function) :: any
  defmacro with_real_api(do: block) do
    quote do
      old_mock = Application.get_env(:code_corps, :github)
      Application.put_env(:code_corps, :github, CodeCorps.GitHub.API.Gateway)

      unquote(block)

      Application.put_env(:code_corps, :github, old_mock)
    end
  end
end
