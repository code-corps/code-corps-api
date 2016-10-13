defmodule CodeCorps.UserSkillControllerTest do
  use CodeCorps.ApiCase

  alias CodeCorps.UserSkill
  alias CodeCorps.Repo

  defp build_payload, do: %{ "data" => %{"type" => "user-skill", "attributes" => %{}}}
  defp put_relationships(payload, user, skill) do
    relationships = build_relationships(user, skill)
    payload |> put_in(["data", "relationships"], relationships)
  end

  defp build_relationships(user, skill) do
    %{
      user: %{data: %{id: user.id}},
      skill: %{data: %{id: skill.id}}
    }
  end

  describe "index" do
    test "lists all entries on index", %{conn: conn} do
      path = conn |> user_skill_path(:index)
      json = conn |> get(path) |> json_response(200)

      assert json["data"] == []
    end

    test "filters resources on index", %{conn: conn} do
      elixir = insert(:skill, title: "Elixir")
      phoenix = insert(:skill, title: "Phoenix")
      rails = insert(:skill, title: "Rails")

      user = insert(:user)
      user_skill_1 = insert(:user_skill, user: user, skill: elixir)
      user_skill_2 = insert(:user_skill, user: user, skill: phoenix)
      insert(:user_skill, user: user, skill: rails)

      path = "user-skills/?filter[id]=#{user_skill_1.id},#{user_skill_2.id}"
      json = conn |> get(path) |> json_response(200)

      data = json["data"]
      assert length(data) == 2

      [first_result, second_result | _] = data
      assert first_result["id"] == "#{user_skill_1.id}"
      assert second_result["id"] == "#{user_skill_2.id}"
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      user_skill = insert(:user_skill)
      path = conn |> user_skill_path(:show, user_skill)
      json = conn |> get(path) |> json_response(200)

      data = json["data"]
      assert data["id"] == "#{user_skill.id}"
      assert data["type"] == "user-skill"
      assert data["relationships"]["user"]["data"]["id"] == "#{user_skill.user_id}"
      assert data["relationships"]["skill"]["data"]["id"] == "#{user_skill.skill_id}"
    end

    test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
      path = conn |> user_skill_path(:show, -1)
      assert conn |> get(path) |> json_response(:not_found)
    end
  end

  describe "create" do
    @tag authenticated: :admin
    test "creates and renders resource when data is valid", %{conn: conn} do
      user = insert(:user)
      skill = insert(:skill, title: "test-skill")

      payload = build_payload |> put_relationships(user, skill)
      path = conn |> user_skill_path(:create)
      json = conn |> post(path, payload) |> json_response(201)

      id = json["data"]["id"] |> String.to_integer
      user_skill = UserSkill |> Repo.get(id)

      assert json["data"]["id"] == "#{user_skill.id}"
      assert json["data"]["type"] == "user-skill"
      assert json["data"]["relationships"]["user"]["data"]["id"] == "#{user.id}"
      assert json["data"]["relationships"]["skill"]["data"]["id"] == "#{skill.id}"
    end

    @tag authenticated: :admin
    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      payload = build_payload
      path = conn |> user_skill_path(:create)
      json = conn |> post(path, payload) |> json_response(422)

      assert json["errors"] != %{}
    end

    test "does not create resource and renders 401 when unauthenticated", %{conn: conn} do
      path = conn |> user_skill_path(:create)
      assert conn |> post(path) |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 401 when not authorized", %{conn: conn} do
      path = conn |> user_skill_path(:create)
      assert conn |> post(path, build_payload) |> json_response(401)
    end
  end

  describe "delete" do
    @tag authenticated: :admin
    test "deletes resource", %{conn: conn} do
      user_skill = insert(:user_skill)
      path = conn |> user_skill_path(:delete, user_skill)
      assert conn |> delete(path) |> response(204)
    end

    test "does not delete resource and renders 401 when unauthenticated", %{conn: conn} do
      path = conn |> user_skill_path(:delete, "id not important")
      assert conn |> delete(path) |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 401 when not authorized", %{conn: conn} do
      user_skill = insert(:user_skill)
      path = conn |> user_skill_path(:delete, user_skill)
      assert conn |> delete(path) |> json_response(401)
    end

    @tag :authenticated
    test "renders page not found when id is nonexistent on delete", %{conn: conn} do
      path = conn |> user_skill_path(:delete, -1)
      assert conn |> delete(path) |> json_response(404)
    end
  end
end
