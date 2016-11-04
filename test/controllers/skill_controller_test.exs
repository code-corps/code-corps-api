defmodule CodeCorps.SkillControllerTest do
  use CodeCorps.ApiCase, resource_name: :skill

  @valid_attrs %{
    description: "Elixir is a functional, concurrent, general-purpose programming language that runs on the Erlang virtual machine (BEAM).",
    original_row: 1,
    title: "Elixir"
  }
  @invalid_attrs %{title: nil}

  describe "index" do
    test "lists all entries on index", %{conn: conn} do
      [skill_1, skill_2] = insert_pair(:skill)

      conn
      |> request_index
      |> json_response(200)
      |> assert_ids_from_response([skill_1.id, skill_2.id])
    end

    test "filters resources on index", %{conn: conn} do
      [skill_1, skill_2 | _] = insert_list(3, :skill)

      path = "skills/?filter[id]=#{skill_1.id},#{skill_2.id}"

      conn
      |> get(path)
      |> json_response(200)
      |> assert_ids_from_response([skill_1.id, skill_2.id])
    end

    test "returns search results on index", %{conn: conn} do
      ruby = insert(:skill, title: "Ruby")
      rails = insert(:skill, title: "Rails")
      insert(:skill, title: "Phoenix")

      params = %{"query" => "r"}
      path = conn |> skill_path(:index, params)

      conn
      |> get(path)
      |> json_response(200)
      |> assert_ids_from_response([ruby.id, rails.id])
    end

    test "limit filter limits results on index", %{conn: conn} do
      insert_list(6, :skill)

      params = %{"limit" => 5}
      path = conn |> skill_path(:index, params)
      json = conn |> get(path) |> json_response(200)

      returned_skills_length = json["data"] |> length
      assert returned_skills_length == 5
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      skill = insert(:skill)
      conn
      |> request_show(skill)
      |> json_response(200)
      |> Map.get("data")
      |> assert_result_id(skill.id)
    end

    test "renders 404 when id is nonexistent", %{conn: conn} do
      assert conn |> request_show(:not_found) |> json_response(404)
    end
  end

  describe "create" do
    @tag authenticated: :admin
    test "creates and renders resource when data is valid", %{conn: conn} do
      assert conn |> request_create(@valid_attrs) |> json_response(201)
    end

    @tag authenticated: :admin
    test "does not create resource and renders 422 when data is invalid", %{conn: conn} do
      assert conn |> request_create(@invalid_attrs) |> json_response(422)
    end

    test "does not create resource and renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_create |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 403 when not authorized", %{conn: conn} do
      assert conn |> request_create |> json_response(403)
    end
  end
end
