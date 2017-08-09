defmodule CodeCorpsWeb.UserSkillControllerTest do
  use CodeCorpsWeb.ApiCase, resource_name: :user_skill

  describe "index" do
    test "lists all entries on index", %{conn: conn} do
      [user_skill_1, user_skill_2] = insert_pair(:user_skill)

      conn
      |> request_index
      |> json_response(200)
      |> assert_ids_from_response([user_skill_1.id, user_skill_2.id])
    end

    test "filters resources on index", %{conn: conn} do
      [user_skill_1, user_skill_2 | _] = insert_list(3, :user_skill)

      path = "user-skills/?filter[id]=#{user_skill_1.id},#{user_skill_2.id}"

      conn
      |> get(path)
      |> json_response(200)
      |> assert_ids_from_response([user_skill_1.id, user_skill_2.id])
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      user_skill = insert(:user_skill)

      conn
      |> request_show(user_skill)
      |> json_response(200)
      |> assert_id_from_response(user_skill.id)
    end

    test "renders 404 error when id is nonexistent", %{conn: conn} do
      assert conn |> request_show(:not_found) |> json_response(404)
    end
  end

  describe "create" do
    @tag authenticated: :admin
    test "creates and renders resource when data is valid", %{conn: conn, current_user: current_user} do
      user = insert(:user)
      skill = insert(:skill, title: "test-skill")

      attrs = %{user: user, skill: skill}
      assert conn |> request_create(attrs) |> json_response(201)

      user_id = current_user.id
      tracking_properties = %{
        skill: skill.title,
        skill_id: skill.id
      }
      assert_received {:track, ^user_id, "Added User Skill", ^tracking_properties}
    end

    @tag authenticated: :admin
    test "renders 422 when data is invalid", %{conn: conn} do
      invalid_attrs = %{}
      assert conn |> request_create(invalid_attrs) |> json_response(422)
    end

    test "renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_create |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 403 when not authorized", %{conn: conn} do
      assert conn |> request_create |> json_response(403)
    end
  end

  describe "delete" do
    @tag authenticated: :admin
    test "deletes resource", %{conn: conn, current_user: current_user} do
      user_skill = insert(:user_skill)
      assert conn |> request_delete(user_skill.id) |> response(204)

      user_id = current_user.id
      tracking_properties = %{
        skill: user_skill.skill.title,
        skill_id: user_skill.skill.id
      }
      assert_received {:track, ^user_id, "Removed User Skill", ^tracking_properties}
    end

    test "does not delete resource and renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_delete |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 403 when not authorized", %{conn: conn} do
      assert conn |> request_delete |> json_response(403)
    end

    @tag :authenticated
    test "renders page not found when id is nonexistent on delete", %{conn: conn} do
      assert conn |> request_delete(:not_found) |> json_response(404)
    end
  end
end
