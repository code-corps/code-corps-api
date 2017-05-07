defmodule CodeCorpsWeb.TaskControllerTest do
  use CodeCorpsWeb.ApiCase, resource_name: :task

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
      tracking_properties = %{
        task: @valid_attrs.title,
        task_id: String.to_integer(json["data"]["id"]),
        project_id: project.id
      }

      assert_received {:track, ^user_id, "Created Task", ^tracking_properties}
    end

    @tag :authenticated
    test "creates github issue when project is connected to github", %{conn: conn, current_user: current_user} do
      project = insert(:project, github_id: 1)
      task_list = insert(:task_list, project: project)
      attrs = @valid_attrs |> Map.merge(%{project: project, user: current_user, task_list: task_list})
      json = conn |> request_create(attrs) |> json_response(201)
      IO.inspect json
      # check that task has a github id
      assert json["data"]["attributes"]["github_id"] == "1"
    end

    @tag :authenticated
    test "doesnt create github issue when error in Github API call", %{conn: conn, current_user: current_user} do
      project = insert(:project, github_id: 1)
      task_list = insert(:task_list, project: project)
      attrs = @valid_attrs |> Map.merge(%{project: project, user: current_user, task_list: task_list, error_testing: true})
      json = conn |> request_create(attrs) |> json_response(201)

      assert json["data"]["attributes"]["github_id"] == nil
    end

    @tag :authenticated
    test "doesnt create github issue when project is not connected to github", %{conn: conn, current_user: current_user} do
      project = insert(:project)
      task_list = insert(:task_list, project: project)
      attrs = @valid_attrs |> Map.merge(%{project: project, user: current_user, task_list: task_list})
      json = conn |> request_create(attrs) |> json_response(201)

      assert json["data"]["attributes"]["github_id"] == nil
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
      tracking_properties = %{
        task: task.title,
        task_id: task.id,
        project_id: task.project.id
      }

      assert_received {:track, ^user_id, "Edited Task", ^tracking_properties}
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
