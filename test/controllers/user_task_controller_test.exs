defmodule CodeCorps.Web.UserTaskControllerTest do
  @moduledoc false

  use CodeCorps.ApiCase, resource_name: :user_task

  alias CodeCorps.{Repo, Web.UserTask}

  describe "index" do
    test "lists all entries on index", %{conn: conn} do
      [user_task_1, user_task_2] = insert_pair(:user_task)

      conn
      |> request_index
      |> json_response(200)
      |> assert_ids_from_response([user_task_1.id, user_task_2.id])
    end

    test "filters resources on index", %{conn: conn} do
      [user_task_1, user_task_2 | _] = insert_list(3, :user_task)

      path = "user-tasks/?filter[id]=#{user_task_1.id},#{user_task_2.id}"

      conn
      |> get(path)
      |> json_response(200)
      |> assert_ids_from_response([user_task_1.id, user_task_2.id])
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      user = insert(:user)
      task = insert(:task)
      user_task = insert(:user_task, task: task, user: user)

      conn
      |> request_show(user_task)
      |> json_response(200)
      |> assert_id_from_response(user_task.id)
    end

    test "renders 404 error when id is nonexistent", %{conn: conn} do
      assert conn |> request_show(:not_found) |> json_response(404)
    end
  end

  describe "create" do
    @tag :authenticated
    test "creates and renders resource when data is valid", %{conn: conn, current_user: current_user} do
      task = insert(:task, user: current_user)
      user = insert(:user)

      attrs = %{task: task, user: user}
      assert conn |> request_create(attrs) |> json_response(201)
    end

    @tag :authenticated
    test "renders 422 error when data is invalid", %{conn: conn, current_user: current_user} do
      task = insert(:task, user: current_user)

      invalid_attrs = %{task: task, user: nil}
      assert conn |> request_create(invalid_attrs) |> json_response(422)
    end

    test "renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_create |> json_response(401)
    end

    @tag :authenticated
    test "renders 403 when not authorized", %{conn: conn} do
      task = insert(:task)
      user = insert(:user)
      attrs = %{task: task, user: user}

      assert conn |> request_create(attrs) |> json_response(403)
    end
  end

  describe "update" do
    @tag :authenticated
    test "updates chosen resource", %{conn: conn, current_user: current_user} do
      task = insert(:task, user: current_user)
      user_task = insert(:user_task, task: task)
      new_user = insert(:user)

      assert conn |> request_update(user_task, %{user_id: new_user.id}) |> response(200)

      updated_task = Repo.get(UserTask, user_task.id)
      assert updated_task.user_id == new_user.id
    end

    test "renders 401 when unauthenticated", %{conn: conn} do
      user_task = insert(:user_task)
      new_user = insert(:user)

      assert conn |> request_update(user_task, %{user_id: new_user.id}) |> json_response(401)
    end

    @tag :authenticated
    test "renders 404 when id is nonexistent", %{conn: conn} do
      assert conn |> request_update(:not_found) |> json_response(404)
    end
  end

  describe "delete" do
    @tag :authenticated
    test "deletes chosen resource", %{conn: conn, current_user: current_user} do
      task = insert(:task, user: current_user)
      user_task = insert(:user_task, task: task)

      assert conn |> request_delete(user_task) |> response(204)
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
