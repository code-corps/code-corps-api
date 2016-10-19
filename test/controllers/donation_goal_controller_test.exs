defmodule CodeCorps.DonationGoalControllerTest do
  use CodeCorps.ApiCase, resource_name: :donation_goal

  alias CodeCorps.DonationGoal

  @valid_attrs %{amount: 200, current: false, description: "A description", title: "A donation"}
  @invalid_attrs %{description: nil, title: nil}

  describe "index" do
    test "lists all entries on index", %{conn: conn} do
      path = conn |> path_for(:index)
      json = conn |> get(path) |> json_response(200)

      assert json["data"] == []
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
    @tag authenticated: :admin
    test "creates and renders resource when data is valid", %{conn: conn} do
      project = insert(:project)
      attrs = @valid_attrs |> Map.merge(%{project: project})
      json = conn |> request_create(attrs) |> json_response(201)
      assert json["data"]["id"]
      assert Repo.get_by(DonationGoal, @valid_attrs)
    end

    @tag authenticated: :admin
    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      json = conn |> request_create(@invalid_attrs) |> json_response(422)
      assert json["errors"] != %{}
    end

    test "renders 401 when not authenticated", %{conn: conn} do
      assert conn |> request_create(@valid_attrs) |> json_response(401)
    end

    @tag :authenticated
    test "renders 401 when not authorized", %{conn: conn} do
      assert conn |> request_create(@valid_attrs) |> json_response(401)
    end
  end

  describe "update" do
    @tag authenticated: :admin
    test "updates and renders chosen resource when data is valid", %{conn: conn} do
      json = conn |> request_update(@valid_attrs) |> json_response(200)
      assert json["data"]["id"]
      assert Repo.get_by(DonationGoal, @valid_attrs)
    end

    @tag authenticated: :admin
    test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
      json = conn |> request_update(@invalid_attrs) |> json_response(422)
      assert json["errors"] != %{}
    end

    @tag authenticated: :admin
    test "renders 404 when id is nonexistent", %{conn: conn} do
      assert conn |> request_update(:not_found) |> json_response(404)
    end

    test "renders 401 when not authenticated", %{conn: conn} do
      assert conn |> request_update(@valid_attrs) |> json_response(401)
    end

    @tag :authenticated
    test "renders 401 when not authorized", %{conn: conn} do
      assert conn |> request_update(@valid_attrs) |> json_response(401)
    end
  end

  describe "delete" do
    @tag authenticated: :admin
    test "deletes chosen resource", %{conn: conn} do
      donation_goal = insert(:donation_goal)
      assert conn |> request_delete(donation_goal) |> response(204)
      refute Repo.get(DonationGoal, donation_goal.id)
    end

    @tag authenticated: :admin
    test "renders 404 when id is nonexistent", %{conn: conn} do
      assert conn |> request_delete(:not_found) |> json_response(404)
    end

    test "renders 401 when not authenticated", %{conn: conn} do
      assert conn |> request_delete |> json_response(401)
    end

    @tag :authenticated
    test "renders 401 when not authorized", %{conn: conn} do
      assert conn |> request_delete |> json_response(401)
    end
  end
end
