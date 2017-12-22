defmodule CodeCorpsWeb.OrganizationGithubAppInstallationControllerTest do
  use CodeCorpsWeb.ApiCase, resource_name: :organization_github_app_installation

  @attrs %{role: "contributor"}

  describe "index" do
    test "lists all resources", %{conn: conn} do
      [record_1, record_2] = insert_pair(:organization_github_app_installation)

      conn
      |> request_index
      |> json_response(200)
      |> assert_ids_from_response([record_1.id, record_2.id])
    end

    test "filters resources by record id", %{conn: conn} do
      [record_1, record_2 | _] = insert_list(3, :organization_github_app_installation)

      path = "organization-github-app-installations/?filter[id]=#{record_1.id},#{record_2.id}"

      conn
      |> get(path)
      |> json_response(200)
      |> assert_ids_from_response([record_1.id, record_2.id])
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      record = insert(:organization_github_app_installation)
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
      github_app_installation = insert(:github_app_installation)
      organization = insert(:organization, owner: user)
      attrs = @attrs |> Map.merge(%{github_app_installation: github_app_installation, organization: organization})

      assert conn |> request_create(attrs) |> json_response(201)
    end

    @tag :authenticated
    test "does not create resource and renders 422 when data is invalid", %{conn: conn, current_user: user} do
      # only way to trigger a validation error is to provide a non-existant github_app_installation or organization
      # anything else will fail on authorization level
      github_app_installation = build(:github_app_installation)
      organization = insert(:organization, owner: user)
      attrs = @attrs |> Map.merge(%{github_app_installation: github_app_installation, organization: organization})
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

  describe "delete" do
    @tag :authenticated
    test "deletes resource", %{conn: conn, current_user: user} do
      organization = insert(:organization, owner: user)
      record = insert(:organization_github_app_installation, organization: organization)
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
