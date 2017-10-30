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

  @spec setup_real_repo :: %CodeCorps.GithubRepo{}
  def setup_real_repo do
    # Data is from the real repository
    #
    # Uses:
    #
    # - the real repository owner
    # - the real repository name
    # - the real GitHub user id of the repository owner
    # - the real GitHub App id
    repo_owner = "coderly"
    repo_name = "github-app-testing"
    repo_owner_id = 321667
    app_github_id = 63365

    # Create the user
    #
    # Simulates:
    #
    # - user (the repo owner) connecting their account with GitHub
    user = insert(:user, github_id: repo_owner_id)

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
    github_repo = insert(:github_repo, github_app_installation: github_app_installation, name: repo_name)
    insert(:project_github_repo, github_repo: github_repo, project: project)

    # Return the %CodeCorps.GithubRepo{} record
    github_repo
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
