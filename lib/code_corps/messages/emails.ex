defmodule CodeCorps.Messages.Emails do
  @moduledoc """
  Handles email notifications used within the Messages context
  """
  alias CodeCorps.{
    ConversationPart,
    Emails,
    Message,
    Repo,
    User
  }

  @message_preloads [:project, [conversations: :user]]

  @doc ~S"""
  Notifies all the recipients of a new `CodeCorps.Message`.

  Target recipients are found in the `user` relationship of each
  `CodeCorps.Conversation`.
  """
  @spec notify_message_targets(Message.t) :: :ok
  def notify_message_targets(%Message{initiated_by: "admin"} = message) do
    message = message |> Repo.preload(@message_preloads)

    message
    |> Map.get(:conversations)
    |> Enum.each(&Emails.send_message_initiated_by_project_email(message, &1))
  end

  @part_preloads [
    :author,
    conversation: [
      [conversation_parts: :author],
      [message: [:author, [project: :organization]]],
      :user
    ]
  ]

  @doc ~S"""
  Notifies users via email when a `CodeCorps.ConversationPart` has been added
  to a `CodeCorps.Conversation`.

  Sends to users participating in the conversation, excluding the author of the
  conversation part.
  """
  @spec notify_of_new_reply(ConversationPart.t) :: :ok
  def notify_of_new_reply(%ConversationPart{} = part) do
    part
    |> Repo.preload(@part_preloads)
    |> send_reply_to_conversation_emails()
  end

  @spec send_reply_to_conversation_emails(ConversationPart.t) :: :ok
  defp send_reply_to_conversation_emails(%ConversationPart{} = part) do
    part
    |> get_conversation_participants()
    |> Enum.each(&Emails.send_reply_to_conversation_email(part, &1))
  end

  @spec get_conversation_participants(ConversationPart.t) :: list(User.t)
  defp get_conversation_participants(%ConversationPart{author_id: author_id} = part) do
    part.conversation.conversation_parts
    |> Enum.map(&Map.get(&1, :author))
    |> Enum.concat([part.conversation.user])
    |> Enum.concat([part.conversation.message.author])
    |> Enum.reject(fn u -> u.id == author_id end)
    |> Enum.uniq()
  end
end
