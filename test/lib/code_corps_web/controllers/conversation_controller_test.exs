defmodule CodeCorpsWeb.ConversationControllerTest do
  use CodeCorpsWeb.ApiCase, resource_name: :conversation

  describe "index" do
    @tag :authenticated
    test "lists all entries user is authorized to view", %{conn: conn, current_user: user} do
      %{project: project} = insert(:project_user, role: "admin", user: user)
      message_on_user_administered_project = insert(:message, project: project)
      conversation_on_user_administered_project =
        insert(:conversation, message: message_on_user_administered_project)
      conversation_by_user = insert(:conversation, user: user)
      _other_conversation = insert(:conversation)

      conn
      |> request_index
      |> json_response(200)
      |> assert_ids_from_response([
        conversation_on_user_administered_project.id,
        conversation_by_user.id
      ])
    end

    @tag authenticated: :admin
    test "lists all entries if user is admin", %{conn: conn} do
      [conversation_1, conversation_2] = insert_pair(:conversation)

      conn
      |> request_index
      |> json_response(200)
      |> assert_ids_from_response([conversation_1.id, conversation_2.id])
    end

    @tag authenticated: :admin
    test "lists all entries by status", %{conn: conn} do
      insert_pair(:conversation)
      user = insert(:user)
      conversation_other = insert(:conversation, user: user)

      conn
      |> get("conversations?user_id=#{user.id}")
      |> json_response(200)
      |> assert_ids_from_response([conversation_other.id])
    end
  end

  describe "show" do
    @tag :authenticated
    test "shows chosen resource", %{conn: conn, current_user: user} do
      conversation = insert(:conversation, user: user)

      conn
      |> request_show(conversation)
      |> json_response(200)
      |> assert_id_from_response(conversation.id)
    end

    test "renders 401 when unauthenticated", %{conn: conn} do
      conversation = insert(:conversation)
      assert conn |> request_show(conversation) |> json_response(401)
    end

    @tag :authenticated
    test "renders 403 when unauthorized", %{conn: conn} do
      conversation = insert(:conversation)
      assert conn |> request_show(conversation) |> json_response(403)
    end
  end

  describe "update" do
    @tag authenticated: :admin
    test "updates and renders chosen resource when data is valid", %{conn: conn, current_user: user} do
      %{project: project} = insert(:project_user, role: "admin", user: user)
      message_on_user_administered_project = insert(:message, project: project)
      conversation_on_user_administered_project =
        insert(:conversation, message: message_on_user_administered_project)

      data = 
        conn 
          |> request_update(conversation_on_user_administered_project, %{status: "closed"}) 
          |> json_response(200)
          |> Map.get("data")
      
      assert data["attributes"]["status"] == "closed"
    end

    @tag authenticated: :admin
    test "renders 422 when data is invalid", %{conn: conn, current_user: current_user} do
      conversation = insert(:conversation, user: current_user)
      assert conn |> request_update(conversation, %{status: "wat"}) |> json_response(422)
    end

    test "renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_update |> json_response(401)
    end

    @tag :authenticated
    test "does not update resource and renders 403 when not authorized", %{conn: conn} do
      user = insert(:user)
      insert(:conversation, user: user)
      assert conn |> request_update() |> json_response(403)
    end
  end
end
