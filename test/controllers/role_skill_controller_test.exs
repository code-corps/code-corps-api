defmodule CodeCorps.RoleSkillControllerTest do
  use CodeCorps.ApiCase

  alias CodeCorps.RoleSkill
  alias CodeCorps.Repo

  @valid_attrs %{}
  @invalid_attrs %{}

  defp build_payload, do: %{ "data" => %{"type" => "role-skill", "attributes" => %{}}}
  defp put_relationships(payload, role, skill) do
    relationships = build_relationships(role, skill)
    payload |> put_in(["data", "relationships"], relationships)
  end

  defp build_relationships(role, skill) do
    %{
      role: %{data: %{id: role.id}},
      skill: %{data: %{id: skill.id}}
    }
  end

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

      data = json["data"]
      assert length(data) == 2

      [first_result, second_result | _] = data

      assert first_result["id"] == "#{role_skill_1.id}"
      assert first_result["attributes"] == %{}
      assert first_result["relationships"]["role"]["data"]["id"] == "#{role.id}"
      assert first_result["relationships"]["role"]["data"]["type"] == "role"
      assert first_result["relationships"]["skill"]["data"]["id"] == "#{elixir.id}"
      assert first_result["relationships"]["skill"]["data"]["type"] == "skill"

      assert second_result["id"] == "#{role_skill_2.id}"
      assert second_result["attributes"] == %{}
      assert second_result["relationships"]["role"]["data"]["id"] == "#{role.id}"
      assert second_result["relationships"]["role"]["data"]["type"] == "role"
      assert second_result["relationships"]["skill"]["data"]["id"] == "#{phoenix.id}"
      assert second_result["relationships"]["skill"]["data"]["type"] == "skill"
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      role_skill = insert(:role_skill)

      path = conn |> role_skill_path(:show, role_skill)
      json = conn |> get(path) |> json_response(200)

      data = json["data"]
      assert data["id"] == "#{role_skill.id}"
      assert data["type"] == "role-skill"
      assert data["attributes"] == %{}
      assert data["relationships"]["role"]["data"]["id"] == "#{role_skill.role_id}"
      assert data["relationships"]["role"]["data"]["type"] == "role"
      assert data["relationships"]["skill"]["data"]["id"] == "#{role_skill.skill_id}"
      assert data["relationships"]["skill"]["data"]["type"] == "skill"
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

      assert json["data"]["id"] == "#{role_skill.id}"
      assert json["data"]["type"] == "role-skill"
      assert json["data"]["attributes"] == %{}
      assert json["data"]["relationships"]["role"]["data"]["id"] == "#{role.id}"
      assert json["data"]["relationships"]["role"]["data"]["type"] == "role"
      assert json["data"]["relationships"]["skill"]["data"]["id"] == "#{skill.id}"
      assert json["data"]["relationships"]["skill"]["data"]["type"] == "skill"
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
