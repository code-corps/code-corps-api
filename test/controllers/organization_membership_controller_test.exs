defmodule CodeCorps.OrganizationMembershipControllerTest do
  use CodeCorps.ApiCase

  alias CodeCorps.OrganizationMembership
  alias CodeCorps.Organization
  alias CodeCorps.User

  @valid_attrs %{role: "contributor"}
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

  defp assert_role(data, role) do
    assert data["attributes"]["role"] == role
    data
  end

  describe "index" do
    test "lists all resources", %{conn: conn} do
      [membership_1, membership_2] = insert_pair(:organization_membership)

      path = conn |> organization_membership_path(:index)
      response = conn |> get(path) |> json_response(200)

      assert ids_from_response(response) == [membership_1.id, membership_2.id]
    end

    test "filters resources by membership id", %{conn: conn} do
      [membership_1, membership_2] = insert_pair(:organization_membership)
      insert(:organization_membership)

      params = %{"filter" => %{"id" => "#{membership_1.id},#{membership_2.id}"}}
      response =
        conn
        |> get(organization_membership_path(conn, :index, params))
        |> json_response(200)

      assert ids_from_response(response) == [membership_1.id, membership_2.id]
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      membership = insert(:organization_membership, role: "admin")

      path = conn |> organization_membership_path(:show, membership)

      conn
      |> get(path)
      |> json_response(200)
      |> assert_jsonapi_relationship("organization", membership.organization.id)
      |> assert_jsonapi_relationship("member", membership.member.id)
      |> Map.get("data")
      |> assert_result_id(membership.id)
      |> assert_role("admin")
    end

    test "renders page not found when id is nonexistent", %{conn: conn} do
      path = conn |> organization_membership_path(:show, -1)
      assert conn |> get(path) |> json_response(:not_found)
    end
  end

  describe "create" do
    @tag :authenticated
    test "creates and renders resource when data is valid", %{conn: conn, current_user: member} do
      organization = insert(:organization)

      payload = build_payload |> put_relationships(organization, member)

      path = conn |> organization_membership_path(:create)
      response =
        conn
        |> post(path, payload)
        |> json_response(201)
        |> assert_jsonapi_relationship("organization", organization.id)
        |> assert_jsonapi_relationship("member", member.id)

      data = response |> Map.get("data") |> assert_role("pending")

      membership = OrganizationMembership |> Repo.get(data["id"])
      assert membership
      assert membership.role == "pending"
      assert membership.organization_id == organization.id
      assert membership.member_id == member.id
    end

    @tag :authenticated
    test "does not create resource and renders 422 when data is invalid", %{conn: conn, current_user: member} do
      # only way to trigger a validation error is to provide a non-existant organization
      # anything else will fail on authorization level
      organization = build(:organization)
      payload = build_payload |> put_relationships(organization, member)

      path = conn |> organization_membership_path(:create)
      data = conn |> post(path, payload) |> json_response(422)

      assert data["errors"] != %{}
    end
  end

  describe "update" do
    @tag :authenticated
    test "updates and renders resource when data is valid", %{conn: conn, current_user: current_user} do
      organization = insert(:organization)
      membership = insert(:organization_membership, organization: organization, role: "pending")
      insert(:organization_membership, organization: organization, member: current_user, role: "owner")

      payload = build_payload |> put_id(membership.id) |> put_attributes(@valid_attrs)

      path = conn |> organization_membership_path(:update, membership)

      response =
        conn
        |> put(path, payload)
        |> json_response(200)
        |> assert_jsonapi_relationship("organization", membership.organization.id)
        |> assert_jsonapi_relationship("member", membership.member.id)

      data = response |> Map.get("data") |> assert_role("contributor")

      membership = OrganizationMembership |> Repo.get(data["id"])
      assert membership
      assert membership.role == "contributor"
      assert membership.organization_id == membership.organization_id
      assert membership.member_id == membership.member_id
    end

    test "doesn't update and renders 401 when unauthenticated", %{conn: conn} do
      path = conn |> organization_membership_path(:update, "id doesn't matter")
      conn = conn |> put(path)

      assert conn |> json_response(401)
    end

    @tag :authenticated
    test "doesn't update and renders 401 when not authorized", %{conn: conn} do
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
      payload = build_payload |> put_id(-1) |> put_attributes(@valid_attrs)

      path = conn |> organization_membership_path(:update, -1)
      assert conn |> put(path, payload) |> json_response(:not_found)
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

    test "doesn't delete and renders 401 when unauthenticated", %{conn: conn} do
      path = conn |> organization_membership_path(:delete, "id doesn't matter")
      conn = conn |> delete(path)

      assert conn |> json_response(401)
    end

    @tag :authenticated
    test "doesn't delete and renders 401 when not authorized", %{conn: conn} do
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
