defmodule CodeCorps.RoleSkillControllerTest do
  use CodeCorps.ApiCase

  alias CodeCorps.RoleSkill
  alias CodeCorps.Repo

  @valid_attrs %{}
  @invalid_attrs %{}

  defp build_payload, do: %{ "data" => %{"type" => "role-skill", "attributes" => %{}}}

  describe "index" do
    test "lists all entries on index", %{conn: conn} do
      path = conn |> role_skill_path(:index)
      json = conn |> get(path) |> json_response(200)
      assert json["data"] == []
    end

    test "filters resources on index", %{conn: conn} do
      elixir = insert(:skill, title: "Elixir")
      phoenix = insert(:skill, title: "Phoenix")
      rails = insert(:skill, title: "Rails")

      role = insert(:role)
      role_skill_1 = insert(:role_skill, role: role, skill: elixir)
      role_skill_2 = insert(:role_skill, role: role, skill: phoenix)
      insert(:role_skill, role: role, skill: rails)

      path = "role-skills/?filter[id]=#{role_skill_1.id},#{role_skill_2.id}"
      json = conn |> get(path) |> json_response(200)

      [first_result, second_result | _rest] = json |> Map.get("data")

      first_result
      |> assert_result_id(role_skill_1.id)
      |> assert_jsonapi_relationship("role", role.id)
      |> assert_jsonapi_relationship("skill", elixir.id)

      assert first_result["attributes"] == %{}

      second_result
      |> assert_result_id(role_skill_2.id)
      |> assert_jsonapi_relationship("role", role.id)
      |> assert_jsonapi_relationship("skill", phoenix.id)

      assert second_result["attributes"] == %{}
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      role_skill = insert(:role_skill)

      path = conn |> role_skill_path(:show, role_skill)
      json = conn |> get(path) |> json_response(200)

      json
      |> Map.get("data")
      |> assert_result_id(role_skill.id)
      |> assert_jsonapi_relationship("role", role_skill.role_id)
      |> assert_jsonapi_relationship("skill", role_skill.skill_id)

      assert json["data"]["attributes"] == %{}
    end

    @tag :authenticated
    test "renders 404 when id is nonexistent", %{conn: conn} do
      path = conn |> role_skill_path(:delete, -1)
      assert conn |> delete(path) |> json_response(404)
    end

    test "does not create resource and renders 401 when unauthenticated", %{conn: conn} do
      path = conn |> role_skill_path(:create)
      assert conn |> post(path) |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 401 when not authorized", %{conn: conn} do
      path = conn |> role_skill_path(:create)
      assert conn |> post(path) |> json_response(401)
    end
  end

  describe "create" do
    @tag authenticated: :admin
    test "creates and renders resource when data is valid", %{conn: conn} do
      role = insert(:role, name: "Frontend Developer")
      skill = insert(:skill, title: "test skill")

      path = conn |> role_skill_path(:create)
      payload = build_payload |> put_relationships(role, skill)

      json = conn |> post(path, payload) |> json_response(201)

      id = json["data"]["id"] |> String.to_integer
      role_skill = RoleSkill |> Repo.get(id)

      json
      |> Map.get("data")
      |> assert_result_id(role_skill.id)
      |> assert_jsonapi_relationship("role", role.id)
      |> assert_jsonapi_relationship("skill", skill.id)

      assert json["data"]["attributes"] == %{}
    end

    @tag authenticated: :admin
    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      path = conn |> role_skill_path(:create)
      payload = build_payload

      json = conn |> post(path, payload) |> json_response(422)
      assert json["errors"] != %{}
    end
  end

  describe "delete" do
    @tag authenticated: :admin
    test "deletes resource", %{conn: conn} do
      role_skill = insert(:role_skill)
      path = conn |> role_skill_path(:delete, role_skill)

      assert conn |> delete(path) |> response(204)

      refute Repo.get(RoleSkill, role_skill.id)
      assert Repo.get(CodeCorps.Role, role_skill.role_id)
      assert Repo.get(CodeCorps.Skill, role_skill.skill_id)
    end

    test "does not delete resource and renders 401 when unauthenticated", %{conn: conn} do
      path = conn |> role_skill_path(:delete, "id not important")
      assert conn |> delete(path) |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 401 when not authorized", %{conn: conn} do
      role_skill = insert(:role_skill)
      path = conn |> role_skill_path(:delete, role_skill)
      assert conn |> delete(path) |> json_response(401)
    end

    @tag :authenticated
    test "renders page not found when id is nonexistent on delete", %{conn: conn} do
      path = conn |> role_skill_path(:delete, -1)
      assert conn |> delete(path) |> json_response(404)
    end
  end
end
