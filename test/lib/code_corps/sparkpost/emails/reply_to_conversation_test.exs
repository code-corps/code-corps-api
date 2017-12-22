defmodule CodeCorps.SparkPost.Emails.ReplyToConversationTest do
  use CodeCorps.DbAccessCase

  alias CodeCorps.{SparkPost.Emails.ReplyToConversation, WebClient}

  describe "build/1" do
    test "provides substitution data for all keys used by template" do
      message = insert(:message)

      preloads = [:author, conversation: [message: [[project: :organization]]]]

      conversation = insert(:conversation, message: message)

      conversation_part =
        :conversation_part
        |> insert(conversation: conversation)
        |> Repo.preload(preloads)

      user = insert(:user)

      %{substitution_data: data} =
        ReplyToConversation.build(conversation_part, user)

      expected_keys =
        "reply-to-conversation"
        |> CodeCorps.SparkPostHelpers.get_keys_used_by_template
      assert data |> Map.keys == expected_keys
    end

    test "builds correct transmission model" do
      message = insert(:message)

      preloads = [:author, conversation: [message: [[project: :organization]]]]

      conversation = insert(:conversation, message: message)

      conversation_part =
        :conversation_part
        |> insert(conversation: conversation)
        |> Repo.preload(preloads)

      %{project: %{organization: %{slug: slug}, slug: project_slug} = project} = message

      user = insert(:user)

      %{substitution_data: data, recipients: [recipient]} =
        ReplyToConversation.build(conversation_part, user)

      assert data.from_name == "Code Corps"
      assert data.from_email == "team@codecorps.org"

      assert data.author_name == conversation_part.author.first_name
      assert data.conversation_url == "#{WebClient.url()}/#{slug}/#{project_slug}/conversations/#{conversation.id}"
      assert data.name == user.first_name
      assert data.project_title == project.title
      assert data.subject == "#{conversation_part.author.first_name} replied to your conversation in #{project.title}"

      assert recipient.address.email == user.email
      assert recipient.address.name == user.first_name
    end
  end
end
