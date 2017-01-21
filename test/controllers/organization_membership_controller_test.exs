defmodule CodeCorps.OrganizationMembershipControllerTest do
  use CodeCorps.ApiCase, resource_name: :organization_membership

  @valid_attrs %{role: "contributor"}

  describe "index" do
    test "lists all resources", %{conn: conn} do
      [membership_1, membership_2] = insert_pair(:organization_membership)

      conn
      |> request_index
      |> json_response(200)
      |> assert_ids_from_response([membership_1.id, membership_2.id])
    end

    test "filters resources by membership id", %{conn: conn} do
      [membership_1, membership_2 | _] = insert_list(3, :organization_membership)

      path = "organization-memberships/?filter[id]=#{membership_1.id},#{membership_2.id}"

      conn
      |> get(path)
      |> json_response(200)
      |> assert_ids_from_response([membership_1.id, membership_2.id])
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      membership = insert(:organization_membership)
      conn
      |> request_show(membership)
      |> json_response(200)
      |> Map.get("data")
      |> assert_result_id(membership.id)
    end

    test "renders 404 when id is nonexistent", %{conn: conn} do
      assert conn |> request_show(:not_found) |> json_response(404)
    end
  end

  describe "create" do
    @tag :authenticated
    test "creates and renders resource when data is valid", %{conn: conn, current_user: member} do
      organization = insert(:organization)
      attrs = @valid_attrs |> Map.merge(%{organization: organization, member: member})

      assert conn |> request_create(attrs) |> json_response(201)

      user_id = member.id
      tracking_properties = %{
        organization: organization.name,
        organization_id: organization.id
      }

      assert_received {:track, ^user_id, "Requested Organization Membership", ^tracking_properties}
    end

    @tag :authenticated
    test "does not create resource and renders 422 when data is invalid", %{conn: conn, current_user: member} do
      # only way to trigger a validation error is to provide a non-existant organization
      # anything else will fail on authorization level
      organization = build(:organization)
      attrs = @valid_attrs |> Map.merge(%{organization: organization, member: member})
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
    test "updates and renders resource when data is valid", %{conn: conn, current_user: current_user} do
      organization = insert(:organization)
      membership = insert(:organization_membership, organization: organization, role: "pending")
      insert(:organization_membership, organization: organization, member: current_user, role: "owner")

      assert conn |> request_update(membership, @valid_attrs) |> json_response(200)

      user_id = current_user.id
      tracking_properties = %{
        organization: organization.name,
        organization_id: organization.id
      }

      assert_received {:track, ^user_id, "Approved Organization Membership", ^tracking_properties}
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
      organization = insert(:organization)
      membership = insert(:organization_membership, organization: organization)
      insert(:organization_membership, organization: organization, member: current_user, role: "owner")

      assert conn |> request_delete(membership) |> response(204)
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
