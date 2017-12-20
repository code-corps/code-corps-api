defmodule CodeCorps.Emails.ReplyToConversationEmailTest do
  use CodeCorps.DbAccessCase
  use Bamboo.Test

  alias CodeCorps.Emails.ReplyToConversationEmail

  test "email works" do
    message = insert(:message)

    preloads = [:author, conversation: [message: [[project: :organization]]]]

    conversation = insert(:conversation, message: message)

    conversation_part =
      :conversation_part
      |> insert(conversation: conversation)
      |> Repo.preload(preloads)

    %{project: %{organization: %{slug: slug}, slug: project_slug} = project} = message

    user = insert(:user)

    email = ReplyToConversationEmail.create(conversation_part, user)
    assert email.from == "Code Corps<team@codecorps.org>"
    assert email.to == user.email

    template_model = email.private.template_model

    assert template_model == %{
      author_name: conversation_part.author.first_name,
      conversation_url: "http://localhost:4200/#{slug}/#{project_slug}/conversations/#{conversation.id}",
      name: user.first_name,
      project_title: project.title,
      subject: "#{conversation_part.author.first_name} replied to your conversation in #{project.title}"
    }
  end
end
