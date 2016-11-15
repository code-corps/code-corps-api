defmodule CodeCorps.TaskControllerTest do
  use CodeCorps.ApiCase, resource_name: :task

  @valid_attrs %{
    title: "Test task",
    task_type: "issue",
    markdown: "A test task",
    status: "open"
  }

  @invalid_attrs %{
    title: nil,
    task_type: "issue",
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

    test "lists all entries newest first", %{conn: conn} do
      # Has to be done manually. Inserting as a list is too quick.
      # Field lacks the resolution to differentiate.
      task_1 = insert(:task, inserted_at: Ecto.DateTime.cast!("2000-01-15T00:00:10"))
      task_2 = insert(:task, inserted_at: Ecto.DateTime.cast!("2000-01-15T00:00:20"))
      task_3 = insert(:task, inserted_at: Ecto.DateTime.cast!("2000-01-15T00:00:30"))

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

    test "lists all tasks filtered by task_type", %{conn: conn} do
      project_1 = insert(:project)
      user = insert(:user)
      insert(:task, task_type: "idea", project: project_1, user: user)
      insert(:task, task_type: "issue", project: project_1, user: user)
      insert(:task, task_type: "task", project: project_1, user: user)

      json =
        conn
        |> get("projects/#{project_1.id}/tasks?task_type=idea,issue")
        |> json_response(200)

      assert json["data"] |> Enum.count == 2

      task_types =
        json["data"]
        |> Enum.map(fn(task_json) -> task_json["attributes"] end)
        |> Enum.map(fn(task_attributes) -> task_attributes["task-type"] end)

      assert task_types |> Enum.member?("issue")
      assert task_types |> Enum.member?("idea")
      refute task_types |> Enum.member?("task")
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
      |> Map.get("data")
      |> assert_result_id(task.id)
    end

    test "shows task by number for project", %{conn: conn} do
      task = insert(:task)

      path = conn |> project_task_path(:show, task.project_id, task.number)
      data = conn |> get(path) |> json_response(200) |> Map.get("data")

      assert data["id"] == "#{task.id}"
      assert data["type"] == "task"
    end

    test "renders 404 when id is nonexistent", %{conn: conn} do
      assert conn |> request_show(:not_found) |> json_response(404)
    end
  end

  describe "create" do
    @tag :authenticated
    test "creates and renders resource when data is valid", %{conn: conn, current_user: current_user} do
      project = insert(:project)
      attrs = @valid_attrs |> Map.merge(%{project: project, user: current_user})
      json = conn |> request_create(attrs) |> json_response(201)

      # ensure record is reloaded from database before serialized, since number is added
      # on database level upon insert
      assert json["data"]["attributes"]["number"] == 1
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

  describe "pagination" do
    test "specifying a page size works", %{conn: conn} do
      project_1 = insert(:project)
      user = insert(:user)
      insert_list(3, :task, project: project_1, user: user)

      path = conn |> task_path(:index)
      json =
        conn
        |> get(path, page: %{page_size: 2})
        |> json_response(200)

      assert json["data"] |> Enum.count == 2
    end

    test "specifying a page number works", %{conn: conn} do
      project_1 = insert(:project)
      user = insert(:user)

      insert_list(2, :task, project: project_1, user: user)
      task_to_test = insert(:task, project: project_1, user: user)
      insert(:task, project: project_1, user: user)

      path = conn |> task_path(:index)
      json =
        conn
        |> get(path, page: %{ page: 2, page_size: 2 })
        |> json_response(200)

      [ %{"id" => id} | _ ] = json["data"]

      assert String.to_integer(id) == task_to_test.id
    end

    test "paginated results include a valid meta key", %{conn: conn} do
      project_1 = insert(:project)
      user = insert(:user)
      insert_list(6, :task, project: project_1, user: user)

      meta = %{
        "total_records" => 6,
        "total_pages" => 3,
        "page_size" => 2,
        "current_page" => 1,
      }
      path = conn |> task_path(:index)
      json =
        conn
        |> get(path, page: %{ page_size: 2 })
        |> json_response(200)

      assert json["meta"] == meta
    end
  end
end
