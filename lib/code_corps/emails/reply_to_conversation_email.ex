defmodule CodeCorps.Emails.ReplyToConversationEmail do
  import Bamboo.Email, only: [to: 2]
  import Bamboo.PostmarkHelper

  alias CodeCorps.{
    Conversation,
    ConversationPart,
    Emails.BaseEmail,
    Message,
    Organization,
    Project,
    User,
    WebClient
  }

  @spec create(ConversationPart.t, User.t) :: Bamboo.Email.t
  def create(
    %ConversationPart{
      author: %User{} = author,
      conversation: %Conversation{
        message: %Message{
          project: %Project{} = project
        }
      } = conversation
    },
    %User{} = user) do

    BaseEmail.create
    |> to(user.email)
    |> template(template_id(), %{
      author_name: author.first_name,
      conversation_url: project |> conversation_url(conversation),
      name: user.first_name,
      project_title: project.title,
      subject: "#{author.first_name} replied to your conversation in #{project.title}"
    })
  end

  @spec template_id :: String.t
  defp template_id, do: Application.get_env(:code_corps, :postmark_reply_to_conversation_template)

  @spec conversation_url(Project.t, Conversation.t) :: String.t
  defp conversation_url(
    %Project{organization: %Organization{slug: slug}, slug: project_slug},
    %Conversation{id: id}) do

    WebClient.url()
    |> URI.merge("#{slug}/#{project_slug}/conversations/#{id}")
    |> URI.to_string
  end
end
