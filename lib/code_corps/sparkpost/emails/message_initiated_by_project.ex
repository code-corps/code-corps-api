defmodule CodeCorps.SparkPost.Emails.MessageInitiatedByProject do
  alias SparkPost.{Content, Transmission}
  alias CodeCorps.{
    Conversation,
    Message,
    Project,
    SparkPost.Emails.Recipient,
    User,
    WebClient
  }

  @spec build(User.t, String.t) :: %Transmission{}
  def build(
    %Message{project: %Project{} = project},
    %Conversation{user: %User{} = user} = conversation) do

    %Transmission{
      content: %Content.TemplateRef{template_id: "message-initiated-by-project"},
      options: %Transmission.Options{inline_css: true},
      recipients: [user |> Recipient.build],
      substitution_data: %{
        conversation_url: conversation |> conversation_url(),
        from_name: "Code Corps",
        from_email: "team@codecorps.org",
        name: user.first_name,
        project_title: project.title,
        subject: "You have a new message from #{project.title}"
      }
    }
  end

  @spec conversation_url(Conversation.t) :: String.t
  defp conversation_url(%Conversation{id: id}) do
    WebClient.url()
    |> URI.merge("conversations/#{id}")
    |> URI.to_string
  end
end
