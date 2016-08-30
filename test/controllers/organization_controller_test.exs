defmodule CodeCorps.OrganizationControllerTest do
  use CodeCorps.ApiCase

  alias CodeCorps.Organization
  alias CodeCorps.Repo
  alias CodeCorps.SluggedRoute

  @valid_attrs %{description: "Build a better future.", name: "Code Corps"}
  @invalid_attrs %{name: ""}

  defp build_payload, do: %{ "data" => %{"type" => "organization"}}
  defp put_id(payload, id), do: payload |> put_in(["data", "id"], id)
  defp put_attributes(payload, attributes), do: payload |> put_in(["data", "attributes"], attributes)

  describe "index" do
    test "lists all entries on index", %{conn: conn} do
      path = conn |> organization_path(:index)
      conn = conn |> get(path)

      assert json_response(conn, 200)["data"] == []
    end

    test "filters resources on index", %{conn: conn} do
      first_org = insert(:organization, name: "Org A")
      second_org = insert(:organization, name: "Org B")
      insert(:organization, name: "Org C")

      path = "organizations/?filter[id]=#{first_org.id},#{second_org.id}"
      conn = conn |> get(path)

      data = json_response(conn, 200)["data"]

      [first_result, second_result | _] = data
      assert length(data) == 2
      assert first_result["id"] == "#{first_org.id}"
      assert second_result["id"] == "#{second_org.id}"
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      organization = insert(:organization)

      path = conn |> organization_path(:show, organization)
      conn = conn |> get(path)

      data = json_response(conn, 200)["data"]

      assert data["id"] == "#{organization.id}"
      assert data["type"] == "organization"
      assert data["attributes"]["name"] == organization.name
      assert data["attributes"]["description"] == organization.description
      assert data["attributes"]["slug"] == organization.slug
    end

    test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
      assert_error_sent 404, fn ->
        path = conn |> organization_path(:show, -1)
        conn |> get(path)
      end
    end
  end

  describe "create" do
    @tag authenticated: :admin
    test "creates and renders resource when data is valid", %{conn: conn} do
      payload =
        build_payload
        |> put_attributes(@valid_attrs)

      path = conn |> organization_path(:create)
      conn = conn |> post(path, payload)

      organization_id = json_response(conn, 201)["data"]["id"]
      assert organization_id
      organization = Repo.get_by(Organization, @valid_attrs)
      assert organization
      slugged_route = Repo.get_by(SluggedRoute, slug: "code-corps")
      assert slugged_route
      assert organization.id == slugged_route.organization_id
    end

    @tag authenticated: :admin
    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      payload =
        build_payload
        |> put_attributes(@invalid_attrs)

      path = conn |> organization_path(:create)
      conn = conn |> post(path, payload)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "does not create resource and renders 401 when not authenticated", %{conn: conn} do
      payload =
        build_payload
        |> put_attributes(@invalid_attrs)

      path = conn |> organization_path(:create)
      conn = conn |> post(path, payload)

      assert json_response(conn, 401)
    end

    @tag :authenticated
    test "does not create resource and renders 401 when not authorized", %{conn: conn} do
      payload =
        build_payload
        |> put_attributes(@invalid_attrs)

      path = conn |> organization_path(:create)
      conn = conn |> post(path, payload)

      assert json_response(conn, 401)
    end
  end

  describe "update" do
    @tag :authenticated
    test "updates and renders chosen resource when data is valid", %{conn: conn, current_user: current_user} do
      organization = insert(:organization)
      insert(:organization_membership, organization: organization, member: current_user, role: "admin")

      payload =
        build_payload
        |> put_id(organization)
        |> put_attributes(@valid_attrs)

      path = conn |> organization_path(:update, organization)
      conn = conn |> put(path, payload)

      assert json_response(conn, 200)["data"]["id"]
      assert Repo.get_by(Organization, @valid_attrs)
    end

    @tag :authenticated
    test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, current_user: current_user} do
      organization = insert(:organization)
      insert(:organization_membership, organization: organization, member: current_user, role: "admin")

      payload =
        build_payload
        |> put_id(organization)
        |> put_attributes(@invalid_attrs)

      path = conn |> organization_path(:update, organization)
      conn = conn |> put(path, payload)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "does not update resource and renders 401 when not authenticated", %{conn: conn} do
      organization = insert(:organization)

      payload =
        build_payload
        |> put_id(organization)
        |> put_attributes(@invalid_attrs)

      path = conn |> organization_path(:update, organization)
      conn = conn |> put(path, payload)

      assert json_response(conn, 401)
    end

    @tag :authenticated
    test "does not update resource and renders 401 when not authorized", %{conn: conn, current_user: current_user} do
      organization = insert(:organization)
      insert(:organization_membership, organization: organization, member: current_user, role: "member")

      payload =
        build_payload
        |> put_id(organization)
        |> put_attributes(@invalid_attrs)

      path = conn |> organization_path(:update, organization)
      conn = conn |> put(path, payload)

      assert json_response(conn, 401)
    end

    @tag :requires_env
    @tag :authenticated
    test "uploads a icon to S3", %{conn: conn, current_user: current_user} do
      organization = insert(:organization)
      insert(:organization_membership, organization: organization, member: current_user, role: "admin")

      icon_data = "data:image/gif;base64,R0lGODlhAQABAIAAAAUEBAAAACwAAAAAAQABAAACAkQBADs="
      attrs = Map.put(@valid_attrs, :base64_icon_data, icon_data)

      payload =
        build_payload
        |> put_id(organization)
        |> put_attributes(attrs)

      path = conn |> organization_path(:update, organization)
      conn = conn |> put(path, payload)

      data = json_response(conn, 200)["data"]
      large_url = data["attributes"]["icon-large-url"]
      assert large_url
      assert String.contains? large_url, "/organizations/#{organization.id}/large"
      thumb_url = data["attributes"]["icon-thumb-url"]
      assert thumb_url
      assert String.contains? thumb_url, "/organizations/#{organization.id}/thumb"
    end
  end
end
