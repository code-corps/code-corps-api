defmodule CodeCorps.SparkPost.Emails.MessageInitiatedByProjectTest do
  use CodeCorps.DbAccessCase

  alias CodeCorps.SparkPost.Emails.MessageInitiatedByProject

  test "has a template_id assigned" do
    assert MessageInitiatedByProject.template_id
  end

  describe "build/2" do
    test "provides substitution data for all keys used by template" do
      %{message: message} = conversation =
        insert(:conversation)
        |> Repo.preload([[message: :project], :user])

      %{substitution_data: data} =
        MessageInitiatedByProject.build(message, conversation)

      expected_keys =
        MessageInitiatedByProject.template_id
        |> CodeCorps.SparkPostHelpers.get_keys_used_by_template
      assert data |> Map.keys == expected_keys
    end

    test "builds correct transmission model" do
      %{message: message, user: user} = conversation =
        insert(:conversation)
        |> Repo.preload([[message: :project], :user])

      %{substitution_data: data, recipients: [recipient]} =
        MessageInitiatedByProject.build(message, conversation)

      assert data.from_name == "Code Corps"
      assert data.from_email == "team@codecorps.org"

      assert data.conversation_url == "http://localhost:4200/conversations/#{conversation.id}"
      assert data.name == conversation.user.first_name
      assert data.project_title == message.project.title
      assert data.subject == "You have a new message from #{message.project.title}"

      assert recipient.address.email == user.email
      assert recipient.address.name == user.first_name
    end
  end
end
