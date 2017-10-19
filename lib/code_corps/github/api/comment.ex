defmodule CodeCorps.GitHub.API.Comment do
  @moduledoc ~S"""
  Functions for working with comments on GitHub.
  """

  alias CodeCorps.{
    Comment,
    GitHub,
    GithubAppInstallation,
    GithubComment,
    GithubIssue,
    GithubRepo,
    Task,
    User
  }

  @doc """
  Create a comment on GitHub's API for a `CodeCorps.Comment`.
  """
  @spec create(Comment.t) :: GitHub.response
  def create(
    %Comment{
      task: %Task{
        github_repo: %GithubRepo{
          github_app_installation: %GithubAppInstallation{} = installation
        }
      },
      user: %User{} = user
    } = comment) do

    endpoint = comment |> create_endpoint_for()
    attrs = comment |> GitHub.Adapters.Comment.to_api

    with opts when is_list(opts) <- GitHub.API.opts_for(user, installation) do
      GitHub.request(:post, endpoint, %{}, attrs, opts)
    else
      {:error, github_error} -> {:error, github_error}
    end
  end

  @doc """
  Update a comment on GitHub's API for a `CodeCorps.Comment`.
  """
  @spec update(Comment.t) :: GitHub.response
  def update(
    %Comment{
      task: %Task{
        github_repo: %GithubRepo{
          github_app_installation: %GithubAppInstallation{} = installation
        }
      },
      user: %User{} = user
    } = comment) do

    endpoint = comment |> update_endpoint_for()
    attrs = comment |> GitHub.Adapters.Comment.to_api

    with opts when is_list(opts) <- GitHub.API.opts_for(user, installation) do
      GitHub.request(:patch, endpoint, %{}, attrs, opts)
    else
      {:error, github_error} -> {:error, github_error}
    end
  end

  @spec update_endpoint_for(Comment.t) :: String.t
  defp update_endpoint_for(
    %Comment{
      github_comment: %GithubComment{github_id: id},
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
        github_issue: %GithubIssue{
          number: number
        },
        github_repo: %GithubRepo{
          github_account_login: owner, name: repo
        },
      }
    }) do
    "/repos/#{owner}/#{repo}/issues/#{number}/comments"
  end
end
