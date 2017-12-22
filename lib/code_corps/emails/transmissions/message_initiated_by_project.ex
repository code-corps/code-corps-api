defmodule CodeCorps.Emails.Transmissions.MessageInitiatedByProject do
  alias SparkPost.{Content, Transmission}
  alias CodeCorps.{
    Conversation,
    Message,
    Project,
    Emails.Recipient,
    User,
    WebClient
  }

  @spec build(User.t, String.t) :: %Transmission{}
  def build(
    %Message{project: %Project{} = project},
    %Conversation{user: %User{} = user} = conversation) do

    %Transmission{
      content: %Content.TemplateRef{template_id: template_id()},
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

  @doc ~S"""
  Returns configured template ID for this email
  """
  @spec template_id :: String.t
  def template_id do
    Application.get_env(:code_corps, :sparkpost_message_initiated_by_project_template)
  end
end
