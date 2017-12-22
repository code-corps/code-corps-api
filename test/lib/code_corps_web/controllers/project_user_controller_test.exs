defmodule CodeCorpsWeb.ProjectUserControllerTest do
  use CodeCorpsWeb.ApiCase, resource_name: :project_user

  @attrs %{role: "contributor"}

  alias CodeCorps.{ProjectUser, Repo, SparkPost.Emails}

  describe "index" do
    test "lists all resources", %{conn: conn} do
      [record_1, record_2] = insert_pair(:project_user)

      conn
      |> request_index
      |> json_response(200)
      |> assert_ids_from_response([record_1.id, record_2.id])
    end

    test "filters resources by record id", %{conn: conn} do
      [record_1, record_2 | _] = insert_list(3, :project_user)

      path = "project-users/?filter[id]=#{record_1.id},#{record_2.id}"

      conn
      |> get(path)
      |> json_response(200)
      |> assert_ids_from_response([record_1.id, record_2.id])
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      record = insert(:project_user)

      conn
      |> request_show(record)
      |> json_response(200)
      |> assert_id_from_response(record.id)
    end

    test "renders 404 when id is nonexistent", %{conn: conn} do
      assert conn |> request_show(:not_found) |> json_response(404)
    end
  end

  describe "create" do
    @tag :authenticated
    test "creates and renders resource when data is valid", %{conn: conn, current_user: user} do
      project = insert(:project)
      insert(:project_user, project: project, role: "owner")
      attrs = %{role: "pending", project: project, user: user}

      assert conn |> request_create(attrs) |> json_response(201)

      user_id = user.id

      tracking_properties = %{
        project: project.title,
        project_id: project.id,
        member: user.username,
        member_id: user.id
      }

      assert_received {:track, ^user_id, "Requested Project Membership", ^tracking_properties}

      email =
        ProjectUser
        |> Repo.get_by(role: "pending")
        |> Repo.preload([:project, :user])
        |> Emails.ProjectUserRequest.build()

      assert_received ^email
    end

    @tag :authenticated
    test "does not create resource and renders 422 when data is invalid", %{
      conn: conn,
      current_user: user
    } do
      # only way to trigger a validation error is to provide a non-existent project
      # anything else will fail on authorization level
      project = build(:project)
      attrs = %{role: "pending", project: project, user: user}
      assert conn |> request_create(attrs) |> json_response(422)
    end

    test "does not create resource and renders 401 when not authenticated", %{conn: conn} do
      assert conn |> request_create |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 403 when not authorized", %{conn: conn} do
      assert conn |> request_create |> json_response(403)
    end
  end

  describe "update" do
    @tag :authenticated
    test "updates and renders resource when data is valid", %{
      conn: conn,
      current_user: current_user
    } do
      project = insert(:project)
      record = insert(:project_user, project: project, role: "pending")
      insert(:project_user, project: project, user: current_user, role: "owner")

      assert conn |> request_update(record, @attrs) |> json_response(200)

      user_id = current_user.id

      tracking_properties = %{
        project: project.title,
        project_id: project.id,
        member: record.user.username,
        member_id: record.user.id
      }

      assert_received {:track, ^user_id, "Approved Project Membership", ^tracking_properties}

      email =
        ProjectUser
        |> Repo.get_by(role: "contributor")
        |> Repo.preload([:project, :user])
        |> Emails.ProjectUserAcceptance.build()

      assert_received ^email
    end

    test "doesn't update and renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_update |> json_response(401)
    end

    @tag :authenticated
    test "doesn't update and renders 403 when not authorized", %{conn: conn} do
      assert conn |> request_update |> json_response(403)
    end

    @tag :authenticated
    test "renders 404 when id is nonexistent on update", %{conn: conn} do
      assert conn |> request_update(:not_found) |> json_response(404)
    end
  end

  describe "delete" do
    @tag :authenticated
    test "deletes resource", %{conn: conn, current_user: current_user} do
      project = insert(:project)
      record = insert(:project_user, project: project)
      insert(:project_user, project: project, user: current_user, role: "owner")

      assert conn |> request_delete(record) |> response(204)
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
