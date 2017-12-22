defmodule CodeCorps.Emails do
  alias CodeCorps.Emails.{API, Tasks, Transmissions}

  defdelegate create_templates, to: Tasks
  defdelegate update_templates, to: Tasks

  def send_forgot_password_email(user, token) do
    user |> Transmissions.ForgotPassword.build(token) |> API.send_transmission
  end

  def send_message_initiated_by_project_email(message, conversation) do
    message
    |> Transmissions.MessageInitiatedByProject.build(conversation)
    |> API.send_transmission
  end

  def send_organization_invite_email(invite) do
    invite |> Transmissions.OrganizationInvite.build |> API.send_transmission
  end

  def send_project_approval_request_email(project) do
    project
    |> Transmissions.ProjectApprovalRequest.build
    |> API.send_transmission
  end

  def send_project_approved_email(project) do
    project |> Transmissions.ProjectApproved.build |> API.send_transmission
  end

  def send_project_user_acceptance_email(project_user) do
    project_user
    |> Transmissions.ProjectUserAcceptance.build
    |> API.send_transmission
  end

  def send_project_user_request_email(project_user) do
    project_user
    |> Transmissions.ProjectUserRequest.build
    |> API.send_transmission
  end

  def send_receipt_email(charge, invoice) do
    case charge |> Transmissions.Receipt.build(invoice) do
      %SparkPost.Transmission{} = transmission ->
        transmission |> API.send_transmission
      {:error, reason} -> {:error, reason}
    end
  end

  def send_reply_to_conversation_email(part, user) do
    part
    |> Transmissions.ReplyToConversation.build(user)
    |> API.send_transmission
  end
end
