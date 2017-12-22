defmodule CodeCorps.Emails do
  alias CodeCorps.{
    Conversation,
    ConversationPart,
    Emails.API,
    Emails.Tasks,
    Emails.Transmissions,
    Message,
    OrganizationInvite,
    Project,
    ProjectUser,
    StripeConnectCharge,
    User
  }

  defdelegate create_templates, to: Tasks
  defdelegate update_templates, to: Tasks

  @spec send_forgot_password_email(User.t, String.t) :: API.transmission_result
  def send_forgot_password_email(user, token) do
    user
    |> Transmissions.ForgotPassword.build(token)
    |> API.send_transmission()
  end

  @spec send_message_initiated_by_project_email(Message.t, Conversation.t) :: API.transmission_result
  def send_message_initiated_by_project_email(%Message{} = message, %Conversation{} = conversation) do
    message
    |> Transmissions.MessageInitiatedByProject.build(conversation)
    |> API.send_transmission()
  end

  @spec send_organization_invite_email(OrganizationInvite.t) :: API.transmission_result
  def send_organization_invite_email(%OrganizationInvite{} = invite) do
    invite
    |> Transmissions.OrganizationInvite.build()
    |> API.send_transmission()
  end

  @spec send_project_approval_request_email(Project.t) :: API.transmission_result
  def send_project_approval_request_email(%Project{} = project) do
    project
    |> Transmissions.ProjectApprovalRequest.build()
    |> API.send_transmission()
  end

  @spec send_project_approved_email(Project.t) :: API.transmission_result
  def send_project_approved_email(%Project{} = project) do
    project
    |> Transmissions.ProjectApproved.build()
    |> API.send_transmission()
  end

  @spec send_project_user_acceptance_email(ProjectUser.t) :: API.transmission_result
  def send_project_user_acceptance_email(%ProjectUser{} = project_user) do
    project_user
    |> Transmissions.ProjectUserAcceptance.build()
    |> API.send_transmission()
  end

  @spec send_project_user_request_email(ProjectUser.t) :: API.transmission_result
  def send_project_user_request_email(%ProjectUser{} = project_user) do
    project_user
    |> Transmissions.ProjectUserRequest.build()
    |> API.send_transmission()
  end

  @spec send_receipt_email(StripeConnectCharge.t, Stripe.Invoice.t) :: API.transmission_result
  def send_receipt_email(%StripeConnectCharge{} = charge, %Stripe.Invoice{} = invoice) do
    case charge |> Transmissions.Receipt.build(invoice) do
      %SparkPost.Transmission{} = transmission ->
        transmission |> API.send_transmission
      {:error, reason} -> {:error, reason}
    end
  end

  @spec send_reply_to_conversation_email(ConversationPart.t, User.t) :: API.transmission_result
  def send_reply_to_conversation_email(%ConversationPart{} = part, %User{} = user) do
    part
    |> Transmissions.ReplyToConversation.build(user)
    |> API.send_transmission()
  end
end
