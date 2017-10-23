defmodule CodeCorpsWeb.TaskControllerTest do
  use CodeCorpsWeb.ApiCase, resource_name: :task

  alias CodeCorps.{Analytics.SegmentTraitsBuilder, Task}

  @valid_attrs %{
    title: "Test task",
    markdown: "A test task",
    status: "open"
  }

  @invalid_attrs %{
    title: nil,
    status: "nonexistent"
  }

  describe "index" do
    test "lists all entries", %{conn: conn} do
      [task_1, task_2] = insert_pair(:task)

      conn
      |> request_index
      |> json_response(200)
      |> assert_ids_from_response([task_1.id, task_2.id])
    end

    test "lists all entries, ordered correctly", %{conn: conn} do
      # Has to be done manually. Inserting as a list is too quick.
      # Field lacks the resolution to differentiate.
      task_1 = insert(:task, order: 3000)
      task_2 = insert(:task, order: 2000)
      task_3 = insert(:task, order: 1000)

      path = conn |> task_path(:index)
      json = conn |> get(path) |> json_response(200)

      ids =
        json["data"]
        |> Enum.map(&Map.get(&1, "id"))
        |> Enum.map(&Integer.parse/1)
        |> Enum.map(fn({id, _rem}) -> id end)

      assert ids == [task_3.id, task_2.id, task_1.id]
    end

    test "lists all tasks for a project", %{conn: conn} do
      project_1 = insert(:project)
      project_2 = insert(:project)
      user = insert(:user)
      insert(:task, project: project_1, user: user)
      insert(:task, project: project_1, user: user)
      insert(:task, project: project_2, user: user)

      json =
        conn
        |> get("projects/#{project_1.id}/tasks")
        |> json_response(200)

      assert json["data"] |> Enum.count == 2
    end

    test "lists all tasks filtered by status", %{conn: conn} do
      project = insert(:project)
      task_1 = insert(:task, status: "open", project: project)
      task_2 = insert(:task, status: "closed", project: project)

      json =
        conn
        |> get("projects/#{project.id}/tasks?status=open")
        |> json_response(200)

      assert json["data"] |> Enum.count == 1
      [task] = json["data"]
      assert task["id"] == task_1.id |> Integer.to_string

      json =
        conn
        |> get("projects/#{project.id}/tasks?status=closed")
        |> json_response(200)

      assert json["data"] |> Enum.count == 1
      [task] = json["data"]
      assert task["id"] == task_2.id |> Integer.to_string
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      task = insert(:task)

      conn
      |> request_show(task)
      |> json_response(200)
      |> assert_id_from_response(task.id)
    end

    test "shows task by number for project", %{conn: conn} do
      task = insert(:task)

      path = conn |> project_task_path(:show, task.project_id, task.number)
      data = conn |> get(path) |> json_response(200)

      assert data["data"]["id"] == "#{task.id}"
      assert data["data"]["type"] == "task"
    end

    test "renders 404 when id is nonexistent", %{conn: conn} do
      assert conn |> request_show(:not_found) |> json_response(404)
    end
  end

  describe "create" do
    @tag :authenticated
    test "creates and renders resource when data is valid", %{conn: conn, current_user: current_user} do
      project = insert(:project)
      task_list = insert(:task_list, project: project)
      attrs = @valid_attrs |> Map.merge(%{project: project, user: current_user, task_list: task_list})
      json = conn |> request_create(attrs) |> json_response(201)

      # ensure record is reloaded from database before serialized, since number is added
      # on database level upon insert
      assert json["data"]["attributes"]["number"] == 1

      user_id = current_user.id
      traits = Task |> Repo.one |> SegmentTraitsBuilder.build
      assert_received {:track, ^user_id, "Created Task", ^traits}
    end

    @tag :authenticated
    test "tracks connecting to github", %{conn: conn, current_user: current_user} do
      %{project: project, github_repo: github_repo} =
        insert(:project_github_repo)
      task_list = insert(:task_list, project: project)
      assocs = %{
        project: project,
        user: current_user,
        task_list: task_list,
        github_repo: github_repo
      }

      attrs = @valid_attrs |> Map.merge(assocs)

      conn |> request_create(attrs)

      traits = Task |> Repo.one |> SegmentTraitsBuilder.build
      user_id = current_user.id
      assert_received {:track, ^user_id, "Connected Task to GitHub", ^traits}
    end

    @tag :authenticated
    test "renders 422 when data is invalid", %{conn: conn, current_user: current_user} do
      project = insert(:project)
      attrs = @invalid_attrs |> Map.merge(%{project: project, user: current_user})
      assert conn |> request_create(attrs) |> json_response(422)
    end

    test "renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_create |> json_response(401)
    end
  end

  describe "update" do
    @tag :authenticated
    test "updates and renders chosen resource when data is valid", %{conn: conn, current_user: current_user} do
      task = insert(:task, user: current_user)
      assert conn |> request_update(task, @valid_attrs) |> json_response(200)

      user_id = current_user.id
      traits = Task |> Repo.get(task.id) |> SegmentTraitsBuilder.build
      assert_received {:track, ^user_id, "Edited Task", ^traits}
    end

    @tag :authenticated
    test "tracks connecting to github", %{conn: conn, current_user: current_user} do
      %{project: project, github_repo: github_repo} = insert(:project_github_repo)
      task_list = insert(:task_list, project: project)
      task = insert(:task, task_list: task_list, project: project, user: current_user)

      attrs = @valid_attrs |> Map.merge(%{github_repo_id: github_repo.id})
      conn |> request_update(task, attrs)

      traits = Task |> Repo.get(task.id) |> SegmentTraitsBuilder.build
      user_id = current_user.id
      assert_received {:track, ^user_id, "Connected Task to GitHub", ^traits}
    end

    @tag :authenticated
    test "does not track connecting to github if already connected", %{conn: conn, current_user: current_user} do
      %{project: project, github_repo: github_repo} = insert(:project_github_repo)
      task_list = insert(:task_list, project: project)
      github_issue = insert(:github_issue, github_repo: github_repo)
      task = insert(:task, task_list: task_list, project: project, user: current_user, github_repo: github_repo, github_issue: github_issue)

      attrs = @valid_attrs |> Map.merge(%{github_repo_id: github_repo.id})
      conn |> request_update(task, attrs)

      user_id = current_user.id
      refute_received {:track, ^user_id, "Connected Task to GitHub", _}
    end

    @tag :authenticated
    test "tracks move between task lists", %{conn: conn, current_user: current_user} do
      %{project: project} = task = insert(:task, user: current_user)
      task_list = insert(:task_list, project: project)

      attrs = @valid_attrs |> Map.put(:task_list_id, task_list.id)

      conn |> request_update(task, attrs)

      traits = Task |> Repo.get(task.id) |> SegmentTraitsBuilder.build
      user_id = current_user.id
      assert_received {:track, ^user_id, "Moved Task Between Lists", ^traits}
    end

    @tag :authenticated
    test "does not track move between task lists if no move took place", %{conn: conn, current_user: current_user} do
      task = insert(:task, user: current_user)

      conn |> request_update(task, @valid_attrs)

      user_id = current_user.id
      refute_received {:track, ^user_id, "Moved Task Between Lists", _}
    end

    @tag :authenticated
    test "tracks title change", %{conn: conn, current_user: current_user} do
      task = insert(:task, user: current_user)
      attrs = @valid_attrs |> Map.put(:title, "New title")
      conn |> request_update(task, attrs)

      traits = Task |> Repo.get(task.id) |> SegmentTraitsBuilder.build
      user_id = current_user.id
      assert_received {:track, ^user_id, "Edited Task Title", ^traits}
    end

    @tag :authenticated
    test "does not track title change if none took place", %{conn: conn, current_user: current_user} do
      task = insert(:task, user: current_user)
      attrs = @valid_attrs |> Map.delete(:title)
      conn |> request_update(task, attrs)

      user_id = current_user.id
      refute_received {:track, ^user_id, "Edited Task Title", _}
    end

    @tag :authenticated
    test "tracks closing task", %{conn: conn, current_user: current_user} do
      task = insert(:task, user: current_user, status: "open")
      attrs = @valid_attrs |> Map.put(:status, "closed")
      conn |> request_update(task, attrs)

      traits = Task |> Repo.get(task.id) |> SegmentTraitsBuilder.build
      user_id = current_user.id
      assert_received {:track, ^user_id, "Closed Task", ^traits}
    end

    @tag :authenticated
    test "does not track closing task if no close took place", %{conn: conn, current_user: current_user} do
      task = insert(:task, user: current_user, status: "open")
      attrs = @valid_attrs |> Map.delete(:status)
      conn |> request_update(task, attrs)

      user_id = current_user.id
      refute_received {:track, ^user_id, "Closed Task", _}
    end

    @tag :authenticated
    test "tracks archiving task", %{conn: conn, current_user: current_user} do
      task = insert(:task, user: current_user, archived: false)
      attrs = @valid_attrs |> Map.put(:archived, true)
      conn |> request_update(task, attrs)

      traits = Task |> Repo.get(task.id) |> SegmentTraitsBuilder.build
      user_id = current_user.id
      assert_received {:track, ^user_id, "Archived Task", ^traits}
    end

    @tag :authenticated
    test "does not track archiving task if no archive took place", %{conn: conn, current_user: current_user} do
      task = insert(:task, user: current_user, archived: false)
      attrs = @valid_attrs |> Map.delete(:archived)
      conn |> request_update(task, attrs)

      user_id = current_user.id
      refute_received {:track, ^user_id, "Archived Task", _}
    end

    @tag :authenticated
    test "renders 422 when data is invalid", %{conn: conn, current_user: current_user} do
      task = insert(:task, user: current_user)
      assert conn |> request_update(task, @invalid_attrs) |> json_response(422)
    end

    test "renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_update |> json_response(401)
    end

    @tag :authenticated
    test "does not update resource and renders 403 when not authorized", %{conn: conn} do
      assert conn |> request_update |> json_response(403)
    end
  end
end
