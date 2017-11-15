defmodule CodeCorpsWeb.GithubRepoControllerTest do
  use CodeCorpsWeb.ApiCase, resource_name: :github_repo

  import CodeCorps.GitHub.TestHelpers

  describe "index" do
    test "lists all resources", %{conn: conn} do
      [record_1, record_2] = insert_pair(:github_repo)

      conn
      |> request_index
      |> json_response(200)
      |> assert_ids_from_response([record_1.id, record_2.id])
    end

    test "filters resources by record id", %{conn: conn} do
      [record_1, record_2 | _] = insert_list(3, :github_repo)

      path = "github-repos/?filter[id]=#{record_1.id},#{record_2.id}"

      conn
      |> get(path)
      |> json_response(200)
      |> assert_ids_from_response([record_1.id, record_2.id])
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      record = insert(:github_repo)
      conn
      |> request_show(record)
      |> json_response(200)
      |> assert_id_from_response(record.id)
    end

    test "renders 404 when id is nonexistent", %{conn: conn} do
      assert conn |> request_show(:not_found) |> json_response(404)
    end
  end

  describe "update" do
    @tag :authenticated
    test "updates repo to add project", %{conn: conn, current_user: user} do
      %{project: project} = record = setup_coderly_repo()
      insert(:project_user, project: project, user: user, role: "admin")
      attrs = %{project: project}

      assert conn |> request_update(record, attrs) |> json_response(200)

      user_id = user.id
      tracking_properties = %{
        id: record.id,
        github_account_login: record.github_account_login,
        github_account_type: record.github_account_type,
        github_id: record.github_id,
        github_repo_name: record.name,
        project: project.title,
        project_id: project.id
      }

      assert_received {:track, ^user_id, "Connected GitHub Repo to Project", ^tracking_properties}
    end

    @tag :authenticated
    test "updates repo to remove project", %{conn: conn, current_user: user} do
      %{project: project} = record = setup_coderly_repo()
      insert(:project_user, project: project, user: user, role: "admin")
      attrs = %{project_id: nil}

      assert conn |> request_update(record, attrs) |> json_response(200)

      user_id = user.id
      tracking_properties = %{
        id: record.id,
        github_account_login: record.github_account_login,
        github_account_type: record.github_account_type,
        github_id: record.github_id,
        github_repo_name: record.name,
        project: "",
        project_id: nil
      }

      assert_received {:track, ^user_id, "Disconnected GitHub Repo from Project", ^tracking_properties}
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
end
