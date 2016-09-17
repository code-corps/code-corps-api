defmodule CodeCorps.SkillControllerTest do
  use CodeCorps.ApiCase

  alias CodeCorps.Skill
  alias CodeCorps.Repo

  @valid_attrs %{
    description: "Elixir is a functional, concurrent, general-purpose programming language that runs on the Erlang virtual machine (BEAM).",
    original_row: 1,
    title: "Elixir"
  }
  @invalid_attrs %{}

  defp build_payload, do: %{ "data" => %{"type" => "skill"}}
  defp put_attributes(payload, attributes), do: payload |> put_in(["data", "attributes"], attributes)

  describe "index" do
    test "lists all entries on index", %{conn: conn} do
      path = conn |> skill_path(:index)
      json = conn |> get(path) |> json_response(200)

      assert json["data"] == []
    end

    test "filters resources on index", %{conn: conn} do
      elixir = insert(:skill, title: "Elixir")
      phoenix = insert(:skill, title: "Phoenix")
      insert(:skill, title: "Rails")

      params = %{"filter" => %{"id" => "#{elixir.id},#{phoenix.id}"}}
      path = conn |> skill_path(:index, params)

      json = conn |> get(path) |> json_response(200)

      data = json["data"]
      assert data |> length == 2

      [first_result, second_result | _] = data
      assert first_result["id"] == "#{elixir.id}"
      assert second_result["id"] == "#{phoenix.id}"
    end

    test "returns search results on index", %{conn: conn} do
      ruby = insert(:skill, title: "Ruby")
      rails = insert(:skill, title: "Rails")
      insert(:skill, title: "Phoenix")

      params = %{"query" => "r"}
      path = conn |> skill_path(:index, params)

      json = conn |> get(path) |> json_response(200)
      data = json["data"]

      [first_result, second_result | _] = data
      assert length(data) == 2
      assert first_result["id"] == "#{ruby.id}"
      assert second_result["id"] == "#{rails.id}"
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

      path = conn |> skill_path(:show, skill)
      json = conn |> get(path) |> json_response(200)

      data = json["data"]
      assert data["id"] == "#{skill.id}"
      assert data["type"] == "skill"
      assert data["attributes"]["title"] == skill.title
      assert data["attributes"]["description"] == skill.description
    end

    test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
      assert_error_sent 404, fn ->
        get conn, skill_path(conn, :show, -1)
      end
    end
  end

  describe "create" do
    @tag authenticated: :admin
    test "creates and renders resource when data is valid", %{conn: conn} do
      path = conn |> skill_path(:create)
      payload = build_payload |> put_attributes(@valid_attrs)
      json = conn |> post(path, payload) |> json_response(201)

      assert json["data"]["id"]
      assert Repo.get_by(Skill, @valid_attrs)
    end

    @tag authenticated: :admin
    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      path = conn |> skill_path(:create)
      payload = build_payload |> put_attributes(@invalid_attrs)
      json = conn |> post(path, payload) |> json_response(422)

      assert json["errors"] != %{}
    end

    test "does not create resource and renders 401 when unauthenticated", %{conn: conn} do
      path = conn |> skill_path(:create)
      payload = build_payload |> put_attributes(@valid_attrs)
      assert conn |> post(path, payload) |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 401 when not authorized", %{conn: conn} do
      path = conn |> skill_path(:create)
      payload = build_payload |> put_attributes(@valid_attrs)
      assert conn |> post(path, payload) |> json_response(401)
    end
  end
end
