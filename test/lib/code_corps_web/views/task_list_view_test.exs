defmodule CodeCorpsWeb.TaskListViewTest do
  use CodeCorpsWeb.ViewCase

  test "renders all attributes and relationships properly" do
    user = insert(:user, first_name: "First", last_name: "Last", default_color: "blue")
    host = Application.get_env(:code_corps, :asset_host)
    project = insert(:project)
    task_list = insert(:task_list, order: 1000, project: project)
    task = insert(:task, order: 1000, task_list: task_list, user: user)

    task_list = CodeCorpsWeb.TaskListController.preload(task_list)
    rendered_json =  render(CodeCorpsWeb.TaskListView, "show.json-api", data: task_list)

    expected_json = %{
      "data" => %{
        "attributes" => %{
          "done" => task_list.done,
          "inbox" => task_list.inbox,
          "name" => task_list.name,
          "order" => 1000,
          "pull-requests" => task_list.pull_requests,
          "inserted-at" => task_list.inserted_at,
          "updated-at" => task_list.updated_at,
        },
        "id" => task_list.id |> Integer.to_string,
        "relationships" => %{
          "project" => %{
            "data" => %{
              "id" => task_list.project_id |> Integer.to_string,
              "type" => "project"
            }
          },
          "tasks" => %{
            "data" => [%{
              "id" => task.id |> Integer.to_string,
              "type" => "task"
            }]
          }
        },
        "type" => "task-list",
      },
      "jsonapi" => %{
        "version" => "1.0"
      },
      "included" => [%{
        "attributes" => %{
          "archived" => task.archived, 
          "body" => task.body, 
          "created-at" => task.created_at, 
          "created-from" => task.created_from, 
          "has-github-pull-request" => false,
          "inserted-at" => task.inserted_at, 
          "markdown" => task.markdown, 
          "modified-at" => task.modified_at, 
          "modified-from" => task.modified_from, 
          "number" => task.number, 
          "order" => task.order, 
          "status" => task.status, 
          "title" => task.title, 
          "updated-at" => task.updated_at
        },
        "relationships" => %{
          "github-issue" => %{
            "data" => nil
          },
          "github-repo" => %{
            "data" => nil
          },
          "user-task" => %{
            "data" => nil
          },
          "user" => %{
            "data" => %{
              "id" => task.user.id |> Integer.to_string,
              "type" => "user"
            }
          },
          "github-pull-request" => %{
            "data" => nil
          },
        },
        "id" => task.id |> Integer.to_string, 
        "type" => "task"
      },
      %{
        "attributes" => %{
          "admin" => false,
          "biography" => user.biography,
          "cloudinary-public-id" => nil,
          "email" => "",
          "first-name" => user.first_name,
          "github-avatar-url" => nil,
          "github-id" => nil,
          "github-username" => nil,
          "inserted-at" => user.inserted_at,
          "last-name" => user.last_name,
          "name" => "First Last",
          "photo-large-url" => "#{host}/icons/user_default_large_blue.png",
          "photo-thumb-url" => "#{host}/icons/user_default_thumb_blue.png",
          "sign-up-context" => "default",
          "state" => "signed_up",
          "state-transition" => nil,
          "twitter" => user.twitter,
          "username" => user.username,
          "updated-at" => user.updated_at,
          "website" => user.website
        },
        "id" => user.id |> Integer.to_string, 
        "type" => "user"
      }]
    }

    assert rendered_json == expected_json
  end
end
