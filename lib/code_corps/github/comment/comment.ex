defmodule CodeCorps.GitHub.Comment do
  @moduledoc ~S"""
  Handles GitHub API requests for actions on Comments
  """

  alias CodeCorps.{Comment, GitHub, GithubAppInstallation, GithubRepo, Task, User}

  @spec create(Comment.t) :: GitHub.response
  def create(%Comment{
    task: %Task{
      github_repo: %GithubRepo{
        github_app_installation: %GithubAppInstallation{} = installation
      }
    } = task,
    user:
    %User{} = user} = comment) do

    endpoint = comment |> create_endpoint_for()
    attrs = comment |> GitHub.Adapters.Comment.to_github_comment

    with opts when is_list(opts) <- opts_for(user, installation) do
      GitHub.request(:post, endpoint, %{}, attrs, opts)
    else
      {:error, github_error} -> {:error, github_error}
    end
  end

  @spec update(Comment.t) :: GitHub.response
  def update(%Comment{
    task: %Task{
      github_repo: %GithubRepo{
        github_app_installation: %GithubAppInstallation{} = installation
      }
    } = task,
    user: %User{} = user,
    github_id: id} = comment) do

    endpoint = comment |> update_endpoint_for()
    attrs = comment |> GitHub.Adapters.Comment.to_github_comment

    with opts when is_list(opts) <- opts_for(user, installation) do
      GitHub.request(:patch, endpoint, %{}, attrs, opts)
    else
      {:error, github_error} -> {:error, github_error}
    end
  end

  @spec update_endpoint_for(Comment.t) :: String.t
  defp update_endpoint_for(
    %Comment{
      github_id: id,
      task: %Task{
        github_repo: %GithubRepo{
          github_account_login: owner, name: repo
        }
      }
    }) do
    "/repos/#{owner}/#{repo}/issues/comments/#{id}"
  end

  @spec create_endpoint_for(Comment.t) :: String.t
  defp create_endpoint_for(
    %Comment{
      task: %Task{
        github_issue_number: number,
        github_repo: %GithubRepo{
          github_account_login: owner, name: repo
        },
      }
    }) do
    "/repos/#{owner}/#{repo}/issues/#{number}/comments"
  end

  @spec opts_for(User.t, GithubAppInstallation.t) :: list
  defp opts_for(%User{github_auth_token: nil}, %GithubAppInstallation{} = installation) do
    with {:ok, token} <- installation |> GitHub.Installation.get_access_token do
      [access_token: token]
    else
      {:error, github_error} -> {:error, github_error}
    end
  end
  defp opts_for(%User{github_auth_token: token}, %GithubAppInstallation{}) do
    [access_token: token]
  end
end
