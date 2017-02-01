defmodule CodeCorps.TaskListControllerTest do
  use CodeCorps.ApiCase, resource_name: :task_list

  describe "index" do
    test "lists all entries", %{conn: conn} do
      [task_list_1, task_list_2] = insert_pair(:task_list)

      conn
      |> request_index
      |> json_response(200)
      |> assert_ids_from_response([task_list_1.id, task_list_2.id])
    end

    test "lists all entries by order", %{conn: conn} do
      # Has to be done manually. Inserting as a list is too quick.
      # Field lacks the resolution to differentiate.
      project = insert(:project)
      task_list_1 = insert(:task_list, project: project, order: 2000)
      task_list_2 = insert(:task_list, project: project, order: 1000)
      task_list_3 = insert(:task_list, project: project, order: 3000)

      path = conn |> task_list_path(:index)

      conn
      |> get(path)
      |> json_response(200)
      |> assert_ids_from_response([task_list_2.id, task_list_1.id, task_list_3.id])
    end

    test "lists all task lists for a project", %{conn: conn} do
      project_1 = insert(:project)
      project_2 = insert(:project)
      insert(:task_list, project: project_1)
      insert(:task_list, project: project_1)
      insert(:task_list, project: project_2)

      json =
        conn
        |> get("projects/#{project_1.id}/task-lists")
        |> json_response(200)

      assert json["data"] |> Enum.count == 2
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      task_list = insert(:task_list)

      conn
      |> request_show(task_list)
      |> json_response(200)
      |> Map.get("data")
      |> assert_result_id(task_list.id)
    end

    test "shows task list by id for project", %{conn: conn} do
      task_list = insert(:task_list)

      path = conn |> project_task_list_path(:show, task_list.project_id, task_list.id)
      data = conn |> get(path) |> json_response(200) |> Map.get("data")

      assert data["id"] == "#{task_list.id}"
      assert data["type"] == "task-list"
    end

    test "renders 404 when id is nonexistent", %{conn: conn} do
      assert conn |> request_show(:not_found) |> json_response(404)
    end
  end
end
