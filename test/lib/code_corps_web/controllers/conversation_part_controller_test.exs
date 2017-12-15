defmodule CodeCorpsWeb.ConversationPartControllerTest do
  use CodeCorpsWeb.ApiCase, resource_name: :conversation_part

  @valid_attrs %{
    body: "Test body."
  }

  @invalid_attrs %{
    body: nil
  }

  describe "index" do
    @tag :authenticated
    test "lists all entries user is authorized to view", %{conn: conn, current_user: user} do
      %{project: project} = insert(:project_user, role: "admin", user: user)
      message_on_user_administered_project = insert(:message, project: project)

      conversation_on_user_administered_project =
        insert(:conversation, message: message_on_user_administered_project)
      conversation_part_in_project =
        insert(:conversation_part, conversation: conversation_on_user_administered_project)

      conversation_by_user = insert(:conversation, user: user)
      conversation_part_from_user =
        insert(:conversation_part, conversation: conversation_by_user)

      other_conversation = insert(:conversation)
      _other_part = insert(:conversation_part, conversation: other_conversation)

      conn
      |> request_index
      |> json_response(200)
      |> assert_ids_from_response([
        conversation_part_in_project.id,
        conversation_part_from_user.id
      ])
    end

    @tag authenticated: :admin
    test "lists all entries if user is admin", %{conn: conn} do
      [part_1, part_2] = insert_pair(:conversation_part)

      conn
      |> request_index
      |> json_response(200)
      |> assert_ids_from_response([part_1.id, part_2.id])
    end
  end

  describe "show" do
    @tag :authenticated
    test "shows chosen resource", %{conn: conn, current_user: user} do
      conversation = insert(:conversation, user: user)
      conversation_part = insert(:conversation_part, conversation: conversation)

      conn
      |> request_show(conversation_part)
      |> json_response(200)
      |> assert_id_from_response(conversation_part.id)
    end

    test "renders 401 when unauthenticated", %{conn: conn} do
      conversation_part = insert(:conversation_part)
      assert conn |> request_show(conversation_part) |> json_response(401)
    end

    @tag :authenticated
    test "renders 403 when unauthorized", %{conn: conn} do
      conversation_part = insert(:conversation_part)
      assert conn |> request_show(conversation_part) |> json_response(403)
    end
  end

  describe "create" do
    @tag :authenticated
    test "creates and renders resource when data is valid", %{conn: conn, current_user: user} do
      conversation = insert(:conversation, user: user)
      attrs = @valid_attrs |> Map.merge(%{author_id: user.id, conversation_id: conversation.id})

      assert conn |> request_create(attrs) |> json_response(201)
    end

    @tag :authenticated
    test "does not create resource and renders 422 when data is invalid", %{
      conn: conn,
      current_user: user
    } do
      conversation = insert(:conversation, user: user)
      attrs = @invalid_attrs |> Map.merge(%{author_id: user.id, conversation_id: conversation.id})

      assert conn |> request_create(attrs) |> json_response(422)
    end

    test "does not create resource and renders 401 when not authenticated", %{conn: conn} do
      assert conn |> request_create |> json_response(401)
    end

    @tag :authenticated
    test "renders 403 when not authorized", %{conn: conn} do
      assert conn |> request_create |> json_response(403)
    end
  end
end
