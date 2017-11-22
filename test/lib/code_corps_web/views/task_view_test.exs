defmodule CodeCorpsWeb.TaskViewTest do
  @moduledoc false

  use CodeCorpsWeb.ViewCase

  test "renders all attributes and relationships properly" do
    github_pull_request = insert(:github_pull_request)
    github_issue = insert(:github_issue, github_pull_request: github_pull_request)
    github_repo = insert(:github_repo)
    task = insert(:task, order: 1000, github_issue: github_issue, github_pull_request: github_pull_request, github_repo: github_repo)
    comment = insert(:comment, task: task)
    task_skill = insert(:task_skill, task: task)
    user_task = insert(:user_task, task: task)

    task = CodeCorpsWeb.TaskController.preload(task)
    rendered_json = render(CodeCorpsWeb.TaskView, "show.json-api", data: task)

    expected_json = %{
      "data" => %{
        "attributes" => %{
          "archived" => task.archived,
          "body" => task.body,
          "created-at" => task.created_at,
          "created-from" => task.created_from,
          "has-github-pull-request" => true,
          "inserted-at" => task.inserted_at,
          "markdown" => task.markdown,
          "modified-at" => task.modified_at,
          "modified-from" => task.modified_from,
          "number" => task.number,
          "order" => task.order,
          "overall-status" => "open",
          "status" => task.status,
          "title" => task.title,
          "updated-at" => task.updated_at
        },
        "id" => task.id |> Integer.to_string,
        "relationships" => %{
          "comments" => %{
            "data" => [
              %{
                "id" => comment.id |> Integer.to_string,
                "type" => "comment"
              }
            ]
          },
          "project" => %{
            "data" => %{
              "id" => task.project_id |> Integer.to_string,
              "type" => "project"
            }
          },
          "github-issue" => %{
            "data" => %{
              "id" => task.github_issue_id |> Integer.to_string,
              "type" => "github-issue"
            }
          },
          "github-pull-request" => %{
            "data" => %{
              "id" => task.github_issue.github_pull_request_id |> Integer.to_string,
              "type" => "github-pull-request"
            }
          },
          "github-repo" => %{
            "data" => %{
              "id" => task.github_repo_id |> Integer.to_string,
              "type" => "github-repo"
            }
          },
          "task-skills" => %{
            "data" => [
              %{
                "id" => task_skill.id |> Integer.to_string,
                "type" => "task-skill"
              }
            ]
          },
          "user" => %{
            "data" => %{
              "id" => task.user_id |> Integer.to_string,
              "type" => "user"
            }
          },
          "user-task" => %{
            "data" => %{
              "id" => user_task.id |> Integer.to_string,
              "type" => "user-task"
            }
          },
          "task-list" => %{
            "data" => %{
              "id" => task.task_list_id |> Integer.to_string,
              "type" => "task-list"
            }
          }
        },
        "type" => "task",
      },
      "jsonapi" => %{
        "version" => "1.0"
      }
    }

    assert rendered_json == expected_json
  end

  describe "has-github-pull-request" do
    test "when pull request exists" do
      github_pull_request = insert(:github_pull_request)
      github_issue = insert(:github_issue, github_pull_request: github_pull_request)
      task = insert(:task, github_issue: github_issue)
      task = CodeCorpsWeb.TaskController.preload(task)
      rendered_json = render(CodeCorpsWeb.TaskView, "show.json-api", data: task)
      assert rendered_json["data"]["attributes"]["has-github-pull-request"]
    end

    test "when no pull request exists" do
      task = insert(:task)
      task = CodeCorpsWeb.TaskController.preload(task)
      rendered_json = render(CodeCorpsWeb.TaskView, "show.json-api", data: task)
      refute rendered_json["data"]["attributes"]["has-github-pull-request"]
    end
  end

  describe "overall-status" do
    test "when pull request is open" do
      github_pull_request = insert(:github_pull_request, merged: false, state: "open")
      github_issue = insert(:github_issue, github_pull_request: github_pull_request)
      task = insert(:task, github_issue: github_issue)
      task = CodeCorpsWeb.TaskController.preload(task)
      rendered_json = render(CodeCorpsWeb.TaskView, "show.json-api", data: task)
      assert rendered_json["data"]["attributes"]["overall-status"] == "open"
    end

    test "when pull request is closed" do
      github_pull_request = insert(:github_pull_request, merged: false, state: "closed")
      github_issue = insert(:github_issue, github_pull_request: github_pull_request)
      task = insert(:task, github_issue: github_issue)
      task = CodeCorpsWeb.TaskController.preload(task)
      rendered_json = render(CodeCorpsWeb.TaskView, "show.json-api", data: task)
      assert rendered_json["data"]["attributes"]["overall-status"] == "closed"
    end

    test "when pull request is merged" do
      github_pull_request = insert(:github_pull_request, merged: false, state: "merged")
      github_issue = insert(:github_issue, github_pull_request: github_pull_request)
      task = insert(:task, github_issue: github_issue)
      task = CodeCorpsWeb.TaskController.preload(task)
      rendered_json = render(CodeCorpsWeb.TaskView, "show.json-api", data: task)
      assert rendered_json["data"]["attributes"]["overall-status"] == "merged"
    end

    test "when task is open" do
      task = insert(:task, status: "open")
      task = CodeCorpsWeb.TaskController.preload(task)
      rendered_json = render(CodeCorpsWeb.TaskView, "show.json-api", data: task)
      assert rendered_json["data"]["attributes"]["overall-status"] == "open"
    end

    test "when task is closed" do
      task = insert(:task, status: "closed")
      task = CodeCorpsWeb.TaskController.preload(task)
      rendered_json = render(CodeCorpsWeb.TaskView, "show.json-api", data: task)
      assert rendered_json["data"]["attributes"]["overall-status"] == "closed"
    end
  end
end
