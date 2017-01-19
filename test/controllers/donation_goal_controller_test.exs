defmodule CodeCorps.DonationGoalControllerTest do
  use CodeCorps.ApiCase, resource_name: :donation_goal

  @valid_attrs %{amount: 200, description: "A description"}
  @invalid_attrs %{description: nil}

  describe "index" do
    test "lists all entries on index", %{conn: conn} do
      [donation_goal_1, donation_goal_2] = insert_pair(:donation_goal)

      conn
      |> request_index
      |> json_response(200)
      |> assert_ids_from_response([donation_goal_1.id, donation_goal_2.id])
    end

    test "filters resources on index", %{conn: conn} do
      [donation_goal_1, donation_goal_2 | _] = insert_list(3, :donation_goal)

      path = "donation-goals/?filter[id]=#{donation_goal_1.id},#{donation_goal_2.id}"

      conn
      |> get(path)
      |> json_response(200)
      |> assert_ids_from_response([donation_goal_1.id, donation_goal_2.id])
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      donation_goal = insert(:donation_goal)
      conn
      |> request_show(donation_goal)
      |> json_response(200)
      |> Map.get("data")
      |> assert_result_id(donation_goal.id)
    end

    test "renders 404 when id is nonexistent", %{conn: conn} do
      assert conn |> request_show(:not_found) |> json_response(404)
    end
  end

  describe "create" do
    @tag :authenticated
    test "creates and renders resource when data is valid", %{conn: conn, current_user: current_user} do
      organization = insert(:organization)
      insert(:organization_membership, member: current_user, organization: organization, role: "owner")
      project = insert(:project, organization: organization)

      attrs = @valid_attrs |> Map.merge(%{project: project})
      assert conn |> request_create(attrs) |> json_response(201)

      user_id = current_user.id
      assert_received {:track, ^user_id, "Created Donation Goal", %{}}
    end

    @tag authenticated: :admin
    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      assert conn |> request_create(@invalid_attrs) |> json_response(422)
    end

    test "renders 401 when not authenticated", %{conn: conn} do
      assert conn |> request_create |> json_response(401)
    end

    @tag :authenticated
    test "renders 403 when not authorized", %{conn: conn} do
      assert conn |> request_create |> json_response(403)
    end
  end

  describe "update" do
    @tag :authenticated
    test "updates and renders chosen resource when data is valid", %{conn: conn, current_user: current_user} do
      organization = insert(:organization)
      insert(:organization_membership, member: current_user, organization: organization, role: "owner")
      project = insert(:project, organization: organization)

      donation_goal = insert(:donation_goal, project: project)

      attrs = @valid_attrs |> Map.merge(%{project: project})
      assert conn |> request_update(donation_goal, attrs) |> json_response(200)

      user_id = current_user.id
      assert_received {:track, ^user_id, "Updated Donation Goal", %{}}
    end

    @tag authenticated: :admin
    test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
      assert conn |> request_update(@invalid_attrs) |> json_response(422)
    end

    @tag authenticated: :admin
    test "renders 404 when id is nonexistent", %{conn: conn} do
      assert conn |> request_update(:not_found) |> json_response(404)
    end

    test "renders 401 when not authenticated", %{conn: conn} do
      assert conn |> request_update |> json_response(401)
    end

    @tag :authenticated
    test "renders 403 when not authorized", %{conn: conn} do
      assert conn |> request_update |> json_response(403)
    end
  end

  describe "delete" do
    @tag authenticated: :admin
    test "deletes chosen resource", %{conn: conn} do
      donation_goal = insert(:donation_goal)
      assert conn |> request_delete(donation_goal) |> response(204)
    end

    test "renders 401 when not authenticated", %{conn: conn} do
      assert conn |> request_delete |> json_response(401)
    end

    @tag :authenticated
    test "renders 403 when not authorized", %{conn: conn} do
      assert conn |> request_delete |> json_response(403)
    end

    @tag authenticated: :admin
    test "renders 404 when id is nonexistent", %{conn: conn} do
      assert conn |> request_delete(:not_found) |> json_response(404)
    end
  end
end
