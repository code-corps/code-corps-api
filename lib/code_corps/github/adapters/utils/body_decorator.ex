defmodule CodeCorps.GitHub.Adapters.Utils.BodyDecorator do
  @moduledoc ~S"""
  Decorates and undecorates the body of GitHub issues and comments as needed.
  """

  alias CodeCorps.{
    Comment,
    GithubIssue,
    Task,
    User,
    WebClient
  }

  @separator "\r\n\r\n[//]: # (Please type your edits below this line)\r\n\r\n---"
  @linebreak "\r\n\r\n"

  @spec add_code_corps_header(map, Comment.t | Task.t | GithubIssue.t) :: map
  def add_code_corps_header(%{"body" => body} = attrs, %Comment{user: %User{github_id: nil}} = comment) do
    modified_body = build_header(comment) <> @separator <> @linebreak <> body
    attrs |> Map.put("body", modified_body)
  end
  def add_code_corps_header(%{"body" => body} = attrs, %Task{user: %User{github_id: nil}} = task) do
    modified_body = build_header(task) <> @separator <> @linebreak <> body
    attrs |> Map.put("body", modified_body)
  end
  def add_code_corps_header(%{} = attrs, _), do: attrs

  @spec build_header(Comment.t | Task.t) :: String.t
  defp build_header(%Comment{task: %Task{} = task, user: %User{} = user}), do: do_build_header(task, user)
  defp build_header(%Task{user: %User{} = user} = task), do: do_build_header(task, user)


  @spec do_build_header(Task.t, User.t) :: String.t
  defp do_build_header(%Task{} = task, %User{username: username} = user) do
    "Posted by [**#{username}**](#{user |> WebClient.url}) from [Code Corps](#{task |> WebClient.url})"
  end

  @spec remove_code_corps_header(map) :: map
  def remove_code_corps_header(%{body: _} = attrs) do
    attrs |> Map.update(:body, nil, &clean_body/1)
  end

  @spec clean_body(String.t | nil) :: String.t | nil
  defp clean_body("Posted by " <> @separator <> _rest = body) do
    body
    |> String.split(@separator)
    |> Enum.drop(1) |> Enum.join
    |> String.trim_leading
  end
  defp clean_body(body), do: body
end
