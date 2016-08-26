defmodule CodeCorps.OrganizationMembershipControllerTest do
  use CodeCorps.ConnCase

  alias CodeCorps.OrganizationMembership
  alias CodeCorps.Organization
  alias CodeCorps.User

  setup do
    conn =
      %{build_conn | host: "api."}
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
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
      get conn, organization_membership_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    attrs = %{ role: "admin" }
    organization = insert(:organization)
    member = insert(:user)

    relationships = %{
      organization: %{data: %{id: organization.id}},
      member: %{data: %{id: member.id}}
    }

    params = %{
      "meta" => %{},
      "data" => %{"type" => "organization-membership", "attributes" => attrs, "relationships" => relationships}
    }

    path = conn |> organization_membership_path(:create)

    data = conn |> post(path, params) |> json_response(201) |> Map.get("data")

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

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    params = %{"meta" => %{}, "data" => %{"type" => "organization-membership", "attributes" => %{}}}
    path = conn |> organization_membership_path(:create)

    data = conn |> post(path, params) |> json_response(422)
    assert data["errors"] != %{}
  end

  test "updates and renders resource when data is valid", %{conn: conn} do
    membership = insert(:organization_membership)

    params = %{
      "meta" => %{},
      "data" => %{
        "id" => membership.id,
        "type" => "organization-membership",
        "attributes" => %{"role" => "admin"}
      }
    }

    path = conn |> organization_membership_path(:update, membership)

    data = conn |> put(path, params) |> json_response(200) |> Map.get("data")

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

  test "renders page not found when id is nonexistent on update", %{conn: conn} do
    assert_error_sent 404, fn ->
      params = %{
        "meta" => %{},
        "data" => %{
          "id" => -1,
          "type" => "organization-membership",
          "attributes" => %{"role" => "admin"}
        }
      }
      path = conn |> organization_membership_path(:update, -1)
      conn |> put(path, params)
    end
  end

  test "deletes resource", %{conn: conn} do
    membership = insert(:organization_membership, role: "admin")

    path = conn |> organization_membership_path(:delete, membership)

    assert conn |> delete(path) |> response(204)

    refute Repo.get(OrganizationMembership, membership.id)
    assert Repo.get(Organization, membership.organization_id)
    assert Repo.get(User, membership.member_id)
  end

  test "renders page not found when id is nonexistent on delete", %{conn: conn} do
    assert_error_sent 404, fn ->
      delete conn, organization_membership_path(conn, :delete, -1)
    end
  end
end
