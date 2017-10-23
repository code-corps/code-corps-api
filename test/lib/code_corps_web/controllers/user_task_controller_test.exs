defmodule CodeCorpsWeb.UserTaskControllerTest do
  @moduledoc false

  use CodeCorpsWeb.ApiCase, resource_name: :user_task

  alias CodeCorps.{Analytics.SegmentTraitsBuilder, Repo, UserTask}

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
    test "tracks when current user assigns task to self", %{conn: conn, current_user: current_user} do
      task = insert(:task, user: current_user)

      attrs = %{task: task, user: current_user}
      conn |> request_create(attrs)

      traits = UserTask |> Repo.one |> SegmentTraitsBuilder.build
      user_id = current_user.id

      assert_received {:track, ^user_id, "Assigned Task to Self", ^traits}
    end

    @tag :authenticated
    test "tracks when current user assings task to someone else", %{conn: conn, current_user: current_user} do
      task = insert(:task, user: current_user)
      user = insert(:user)

      attrs = %{task: task, user: user}
      conn |> request_create(attrs)

      traits = UserTask |> Repo.one |> SegmentTraitsBuilder.build
      user_id = current_user.id

      assert_received {:track, ^user_id, "Assigned Task to Someone Else", ^traits}
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
      # task owner or project contributor are the only ones who can re-assign
      task = insert(:task, user: current_user)
      user_task = insert(:user_task, task: task)
      new_user = insert(:user)

      assert conn |> request_update(user_task, %{user_id: new_user.id}) |> response(200)

      updated_task = Repo.get(UserTask, user_task.id)
      assert updated_task.user_id == new_user.id
    end

    @tag :authenticated
    test "tracks when current user assigns task to self", %{conn: conn, current_user: current_user} do
      # task owner or project contributor are the only ones who can re-assign
      task = insert(:task, user: current_user)
      user_task = insert(:user_task, task: task)

      conn |> request_update(user_task,  %{user_id: current_user.id})

      traits = UserTask |> Repo.one |> SegmentTraitsBuilder.build
      user_id = current_user.id

      assert_received {:track, ^user_id, "Assigned Task to Self", ^traits}
    end

    @tag :authenticated
    test "tracks when current user assings task to someone else", %{conn: conn, current_user: current_user} do
      # task owner or project contributor are the only ones who can re-assign
      task = insert(:task, user: current_user)
      user_task = insert(:user_task, task: task)
      new_user = insert(:user)

      conn |> request_update(user_task, %{user_id: new_user.id})

      traits = UserTask |> Repo.one |> SegmentTraitsBuilder.build
      user_id = current_user.id

      assert_received {:track, ^user_id, "Assigned Task to Someone Else", ^traits}
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

    @tag :authenticated
    test "tracks when current user unassigns task from self", %{conn: conn, current_user: current_user} do
      # task owner or project contributor are the only ones who can unassign
      task = insert(:task, user: current_user)
      user_task = insert(:user_task, task: task, user: current_user)

      conn |> request_delete(user_task)

      traits = user_task |> SegmentTraitsBuilder.build
      user_id = current_user.id

      assert_received {:track, ^user_id, "Unassigned Task from Self", ^traits}
    end

    @tag :authenticated
    test "tracks when current user unassings task from someone else", %{conn: conn, current_user: current_user} do
      # task owner or project contributor are the only ones who can unassign
      task = insert(:task, user: current_user)
      user_task = insert(:user_task, task: task)

      conn |> request_delete(user_task)

      traits = user_task |> SegmentTraitsBuilder.build
      user_id = current_user.id

      assert_received {:track, ^user_id, "Unassigned Task from Someone Else", ^traits}
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
