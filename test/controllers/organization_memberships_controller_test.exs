defmodule CodeCorps.OrganizationMembershipControllerTest do
  use CodeCorps.ApiCase

  alias CodeCorps.OrganizationMembership
  alias CodeCorps.Organization
  alias CodeCorps.User

  @valid_attrs %{role: "admin"}
  @invalid_attrs %{role: "invalid_role"}

  defp build_payload, do: %{ "data" => %{"type" => "organization-membership"}}
  defp put_id(payload, id), do: payload |> put_in(["data", "id"], id)
  defp put_attributes(payload, attributes), do: payload |> put_in(["data", "attributes"], attributes)
  defp put_relationships(payload, organization, member) do
    relationships = build_relationships(organization, member)
    payload |> put_in(["data", "relationships"], relationships)
  end

  defp build_relationships(organization, member) do
    %{
      organization: %{data: %{id: organization.id}},
      member: %{data: %{id: member.id}}
    }
  end

  describe "index" do
    test "lists all resources", %{conn: conn} do
      membership_1 = insert(:organization_membership)
      membership_2 = insert(:organization_membership)

      path = conn |> organization_membership_path(:index)

      data = conn |> get(path) |> json_response(200) |> Map.get("data")
      assert data |> length == 2

      [first_result, second_result] = data
      assert first_result["id"] == "#{membership_1.id}"
      assert second_result["id"] == "#{membership_2.id}"
    end

    test "lists all resources for specified organization", %{conn: conn} do
      organization = insert(:organization)
      membership_1 = insert(:organization_membership, organization: organization)
      membership_2 = insert(:organization_membership, organization: organization)
      insert(:organization_membership)

      path = conn |> organization_organization_membership_path(:index, organization)

      data = conn |> get(path) |> json_response(200) |> Map.get("data")
      assert data |> length == 2

      [first_result, second_result] = data
      assert first_result["id"] == "#{membership_1.id}"
      assert second_result["id"] == "#{membership_2.id}"
    end

    test "filters resources by member id", %{conn: conn} do
      member_1 = insert(:user)
      member_2 = insert(:user)
      member_3 = insert(:user)
      membership_1 = insert(:organization_membership, member: member_1)
      membership_2 = insert(:organization_membership, member: member_2)
      insert(:organization_membership, member: member_3)

      params = %{"filter" => %{"id" => "#{member_1.id},#{member_2.id}"}}
      conn = get conn, organization_membership_path(conn, :index, params)
      data = json_response(conn, 200)["data"]
      assert data |> length == 2

      [first_result, second_result] = data
      assert first_result["id"] == "#{membership_1.id}"
      assert second_result["id"] == "#{membership_2.id}"
    end

    test "filters resources by role", %{conn: conn} do
      membership_1 = insert(:organization_membership, role: "admin")
      membership_2 = insert(:organization_membership, role: "admin")
      insert(:organization_membership, role: "owner")

      params = %{"role" => "admin"}
      path = conn |> organization_membership_path(:index, params)

      data = conn |> get(path) |> json_response(200) |> Map.get("data")
      assert data |> length == 2

      [first_result, second_result] = data
      assert first_result["id"] == "#{membership_1.id}"
      assert second_result["id"] == "#{membership_2.id}"
    end

    test "filters resources by role and id", %{conn: conn} do
      member_1 = insert(:user)
      member_2 = insert(:user)
      membership_1 = insert(:organization_membership, role: "admin", member: member_1)
      insert(:organization_membership, role: "admin", member: member_2)
      insert(:organization_membership, role: "owner")

      params = %{"role" => "admin", "filter" => %{"id" => "#{member_1.id}"}}
      path = conn |> organization_membership_path(:index, params)

      data = conn |> get(path) |> json_response(200) |> Map.get("data")

      assert data |> length == 1

      [only_result] = data
      assert only_result["id"] == "#{membership_1.id}"
    end

    test "filters resources by role and id on specific organization", %{conn: conn} do
      member_1 = insert(:user)
      organization = insert(:organization)
      membership_1 =
        insert(
          :organization_membership,
          organization: organization,
          role: "admin",
          member: member_1
        )
      insert(:organization_membership, organization: organization, role: "admin")
      insert(:organization_membership, role: "owner")

      params = %{"role" => "admin", "filter" => %{"id" => "#{member_1.id}"}}
      path = conn |> organization_organization_membership_path(:index, organization)

      data = conn |> get(path, params) |> json_response(200) |> Map.get("data")
      assert data |> length == 1

      [only_result] = data
      assert only_result["id"] == "#{membership_1.id}"
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      membership = insert(:organization_membership, role: "admin")

      path = conn |> organization_membership_path(:show, membership)

      data = conn |> get(path) |> json_response(200) |> Map.get("data")

      assert data["id"] == "#{membership.id}"
      assert data["type"] == "organization-membership"

      assert data["attributes"]["role"] == "admin"
      assert data["relationships"]["organization"]["data"]["id"] |> String.to_integer == membership.organization_id
      assert data["relationships"]["member"]["data"]["id"] |> String.to_integer == membership.member_id
    end

    test "renders page not found when id is nonexistent", %{conn: conn} do
      assert_error_sent 404, fn ->
        path = conn |> organization_membership_path(:show, -1)
        conn |> get(path)
      end
    end
  end

  describe "create" do
    @tag :authenticated
    test "creates and renders resource when data is valid", %{conn: conn} do
      organization = insert(:organization)
      member = insert(:user)

      payload =
        build_payload
        |> put_attributes(@valid_attrs)
        |> put_relationships(organization, member)

      path = conn |> organization_membership_path(:create)
      data = conn |> post(path, payload) |> json_response(201) |> Map.get("data")

      id = data["id"]
      assert data["attributes"]["role"] == "admin"
      assert data["relationships"]["organization"]["data"]["id"] |> String.to_integer == organization.id
      assert data["relationships"]["member"]["data"]["id"] |> String.to_integer == member.id

      membership = OrganizationMembership |> Repo.get(id)
      assert membership
      assert membership.role == "admin"
      assert membership.organization_id == organization.id
      assert membership.member_id == member.id
    end

    @tag :authenticated
    test "does not create resource and renders 422 when data is invalid", %{conn: conn} do
      organization = insert(:organization)
      member = insert(:user)

      payload =
        build_payload
        |> put_attributes(@invalid_attrs)
        |> put_relationships(organization, member)

      path = conn |> organization_membership_path(:create)
      data = conn |> post(path, payload) |> json_response(422)

      assert data["errors"] != %{}
    end
  end

  describe "update" do
    @tag :authenticated
    test "updates and renders resource when data is valid", %{conn: conn, current_user: current_user} do
      organization = insert(:organization)
      membership = insert(:organization_membership, organization: organization)
      insert(:organization_membership, organization: organization, member: current_user, role: "owner")

      payload =
        build_payload
        |> put_id(membership.id)
        |> put_attributes(@valid_attrs)

      path = conn |> organization_membership_path(:update, membership)
      data = conn |> put(path, payload) |> json_response(200) |> Map.get("data")

      id = data["id"]
      assert data["attributes"]["role"] == "admin"
      assert data["relationships"]["organization"]["data"]["id"] |> String.to_integer == membership.organization_id
      assert data["relationships"]["member"]["data"]["id"] |> String.to_integer == membership.member_id

      membership = OrganizationMembership |> Repo.get(id)
      assert membership
      assert membership.role == "admin"
      assert membership.organization_id == membership.organization_id
      assert membership.member_id == membership.member_id
    end

    @tag :authenticated
    test "doesnt't update and renders 422 when data is invalid", %{conn: conn, current_user: current_user} do
      organization = insert(:organization)
      membership = insert(:organization_membership, organization: organization)
      insert(:organization_membership, organization: organization, member: current_user, role: "owner")

      payload =
        build_payload
        |> put_id(membership.id)
        |> put_attributes(@invalid_attrs)

      path = conn |> organization_membership_path(:update, membership)
      conn = conn |> put(path, payload)

      assert conn |> json_response(422)
    end

    test "doesnt't update and renders 401 when unauthenticated", %{conn: conn} do
      path = conn |> organization_membership_path(:update, "id doesn't matter")
      conn = conn |> put(path)

      assert conn |> json_response(401)
    end

    @tag :authenticated
    test "doesnt't update and renders 401 when not authorized", %{conn: conn} do
      membership = insert(:organization_membership)

      payload =
        build_payload
        |> put_id(membership.id)
        |> put_attributes(@valid_attrs)

      path = conn |> organization_membership_path(:update, membership)
      conn = conn |> put(path, payload)

      assert conn |> json_response(401)
    end

    @tag :authenticated
    test "renders page not found when id is nonexistent on update", %{conn: conn} do
      path = conn |> organization_membership_path(:update, -1)
      assert conn |> put(path) |> json_response(:not_found)
    end
  end

  describe "delete" do
    @tag :authenticated
    test "deletes resource", %{conn: conn, current_user: current_user} do
      organization = insert(:organization)
      membership = insert(:organization_membership, organization: organization)
      insert(:organization_membership, organization: organization, member: current_user, role: "owner")

      path = conn |> organization_membership_path(:delete, membership)

      assert conn |> delete(path) |> response(204)

      refute Repo.get(OrganizationMembership, membership.id)
      assert Repo.get(Organization, membership.organization_id)
      assert Repo.get(User, membership.member_id)
    end

    test "doesnt't delete and renders 401 when unauthenticated", %{conn: conn} do
      path = conn |> organization_membership_path(:delete, "id doesn't matter")
      conn = conn |> delete(path)

      assert conn |> json_response(401)
    end

    @tag :authenticated
    test "doesnt't delete and renders 401 when not authorized", %{conn: conn} do
      membership = insert(:organization_membership)

      payload =
        build_payload
        |> put_id(membership.id)
        |> put_attributes(@valid_attrs)

      path = conn |> organization_membership_path(:delete, membership)
      conn = conn |> delete(path, payload)

      assert conn |> json_response(401)
    end

    @tag :authenticated
    test "renders page not found when id is nonexistent on delete", %{conn: conn} do
      path = conn |> organization_membership_path(:delete, -1)
      assert conn |> delete(path) |> json_response(:not_found)
    end
  end
end
