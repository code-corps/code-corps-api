defmodule CodeCorps.Emails.MessageInitiatedByProjectEmail do
  import Bamboo.Email, only: [to: 2]
  import Bamboo.PostmarkHelper

  alias CodeCorps.{
    Conversation,
    Emails.BaseEmail,
    Message,
    Project,
    User,
    WebClient
  }

  @spec create(Message.t, Conversation.t) :: Bamboo.Email.t
  def create(
    %Message{project: %Project{} = project},
    %Conversation{user: %User{} = user} = conversation) do

    BaseEmail.create
    |> to(user.email)
    |> template(template_id(), %{
      conversation_url: conversation |> conversation_url(),
      name: user.first_name,
      project_title: project.title,
      subject: "You have a new message from #{project.title}"
    })
  end

  @spec template_id :: String.t
  defp template_id, do: Application.get_env(:code_corps, :postmark_message_initiated_by_project_template)

  @spec conversation_url(Conversation.t) :: String.t
  defp conversation_url(%Conversation{id: id}) do
    WebClient.url()
    |> URI.merge("conversations/#{id}")
    |> URI.to_string
  end
end
