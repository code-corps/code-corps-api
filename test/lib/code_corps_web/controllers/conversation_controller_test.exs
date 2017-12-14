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
  end
end
