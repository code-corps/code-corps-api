defmodule CodeCorps.Emails.MessageInitiatedByProjectEmailTest do
  use CodeCorps.DbAccessCase
  use Bamboo.Test

  alias CodeCorps.Emails.MessageInitiatedByProjectEmail

  test "email works" do
    %{message: message} = conversation =
      insert(:conversation)
      |> Repo.preload([[message: :project], :user])

    email = MessageInitiatedByProjectEmail.create(message, conversation)
    assert email.from == "Code Corps<team@codecorps.org>"
    assert email.to == conversation.user.email

    template_model = email.private.template_model

    assert template_model == %{
      conversation_url: "http://localhost:4200/conversations/#{conversation.id}",
      name: conversation.user.first_name,
      project_title: message.project.title,
      subject: "You have a new message from #{message.project.title}"
    }
  end
end
