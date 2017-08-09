defmodule CodeCorpsWeb.TaskSkillControllerTest do
  @moduledoc false

  use CodeCorpsWeb.ApiCase, resource_name: :task_skill

  describe "index" do
    test "lists all entries on index", %{conn: conn} do
      [task_skill_1, task_skill_2] = insert_pair(:task_skill)

      conn
      |> request_index
      |> json_response(200)
      |> assert_ids_from_response([task_skill_1.id, task_skill_2.id])
    end

    test "filters resources on index", %{conn: conn} do
      [task_skill_1, task_skill_2 | _] = insert_list(3, :task_skill)

      path = "task-skills/?filter[id]=#{task_skill_1.id},#{task_skill_2.id}"

      conn
      |> get(path)
      |> json_response(200)
      |> assert_ids_from_response([task_skill_1.id, task_skill_2.id])
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      skill = insert(:skill)
      task = insert(:task)
      task_skill = insert(:task_skill, task: task, skill: skill)

      conn
      |> request_show(task_skill)
      |> json_response(200)
      |> assert_id_from_response(task_skill.id)
    end

    test "renders 404 error when id is nonexistent", %{conn: conn} do
      assert conn |> request_show(:not_found) |> json_response(404)
    end
  end

  describe "create" do
    @tag :authenticated
    test "creates and renders resource when data is valid", %{conn: conn, current_user: current_user} do
      task = insert(:task, user: current_user)
      skill = insert(:skill)

      attrs = %{task: task, skill: skill}
      assert conn |> request_create(attrs) |> json_response(201)
    end

    @tag :authenticated
    test "renders 422 error when data is invalid", %{conn: conn, current_user: current_user} do
      task = insert(:task, user: current_user)

      invalid_attrs = %{task: task, skill: nil}
      assert conn |> request_create(invalid_attrs) |> json_response(422)
    end

    test "renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_create |> json_response(401)
    end

    @tag :authenticated
    test "renders 403 when not authorized", %{conn: conn} do
      task = insert(:task)
      skill = insert(:skill)
      attrs = %{task: task, skill: skill}

      assert conn |> request_create(attrs) |> json_response(403)
    end
  end

  describe "delete" do
    @tag :authenticated
    test "deletes chosen resource", %{conn: conn, current_user: current_user} do
      task = insert(:task, user: current_user)
      task_skill = insert(:task_skill, task: task)

      assert conn |> request_delete(task_skill) |> response(204)
    end

    test "renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_delete |> json_response(401)
    end

    @tag :authenticated
    test "renders 403 when not authorized", %{conn: conn} do
      assert conn |> request_delete |> json_response(403)
    end

    @tag :authenticated
    test "renders 404 when id is nonexistent on delete", %{conn: conn} do
      assert conn |> request_delete(:not_found) |> json_response(404)
    end
  end
end
