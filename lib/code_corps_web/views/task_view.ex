defmodule CodeCorpsWeb.TaskView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JSONAPI.View, type: "task"

  alias CodeCorpsWeb.{GithubIssueView, GithubPullRequestView, GithubRepoView, ProjectView,
    TaskListView, UserView, UserTaskView, CommentView, TaskSkillView}

  def fields do
    [:archived, :body, :created_at, :created_from, :inserted_at, :markdown,
    :modified_at, :modified_from, :number, :order, :status, :title, :updated_at]
  end

  def relationships do
    [comments: CommentView, task_skills: TaskSkillView]
  end

# <<<<<<< HEAD
#   has_many :comments, serializer: CodeCorpsWeb.CommentView, identifiers: :always
#   has_many :task_skills, serializer: CodeCorpsWeb.TaskSkillView, identifiers: :always

#   def has_github_pull_request(%{
#     github_pull_request: %CodeCorps.GithubPullRequest{}
#   }), do: true
#   def has_github_pull_request(%{github_pull_request: nil}), do: false

#   def overall_status(%{
#     github_pull_request: %CodeCorps.GithubPullRequest{merged: merged, state: state}
#   }, _conn) do
#     case merged do
#       true -> "merged"
#       false -> state
#     end
#   end
#   def overall_status(%{github_pull_request: nil, status: status}, _conn) do
#     status
#   end
# =======
end
