defmodule CodeCorps.SparkPost do
  alias CodeCorps.SparkPost.{Emails, Tasks}

  defdelegate create_templates, to: Tasks
  defdelegate update_templates, to: Tasks

  defdelegate send_forgot_password_email(user, token), to: Emails
  defdelegate send_message_initiated_by_project_email(message, conversation), to: Emails
  defdelegate send_organization_invite_email(invite), to: Emails
  defdelegate send_receipt_email(charge, invoice), to: Emails
  defdelegate send_reply_to_conversation_email(part, user), to: Emails
end
