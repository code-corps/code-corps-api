defmodule CodeCorps.Emails.Transmissions.ReplyToConversation do
  alias SparkPost.{Content, Transmission}
  alias CodeCorps.{
    Conversation,
    ConversationPart,
    Message,
    Organization,
    Project,
    Emails.Recipient,
    User,
    WebClient
  }

  @spec build(ConversationPart.t, User.t) :: %Transmission{}
  def build(
    %ConversationPart{
      author: %User{} = author,
      conversation: %Conversation{
        message: %Message{
          project: %Project{} = project
        }
      } = conversation
    },
    %User{} = user) do

    %Transmission{
      content: %Content.TemplateRef{template_id: template_id()},
      options: %Transmission.Options{inline_css: true},
      recipients: [user |> Recipient.build],
      substitution_data: %{
        author_name: author.first_name,
        from_name: "Code Corps",
        from_email: "team@codecorps.org",
        conversation_url: project |> conversation_url(conversation),
        name: user |> get_name(),
        project_title: project.title,
        subject: "#{author.first_name} replied to your conversation in #{project.title}"
      }
    }
  end

  @spec conversation_url(Project.t, Conversation.t) :: String.t
  defp conversation_url(
    %Project{organization: %Organization{slug: slug}, slug: project_slug},
    %Conversation{id: id}) do

    WebClient.url()
    |> URI.merge("#{slug}/#{project_slug}/conversations/#{id}")
    |> URI.to_string
  end

  @spec get_name(User.t) :: String.t
  defp get_name(%User{first_name: nil}), do: "there"
  defp get_name(%User{first_name: name}), do: name

  @doc ~S"""
  Returns configured template ID for this email
  """
  @spec template_id :: String.t
  def template_id do
    Application.get_env(:code_corps, :sparkpost_reply_to_conversation_template)
  end
end
