defmodule CodeCorps.Conversation do
  @moduledoc ~S"""
  A header of a `CodeCorps.Message` thread, depicting a start of a conversation
  with a specific `CodeCorps.User`

  When a project sends a `CodeCorps.Message` to one or more users, a
  `CodeCorps.Conversation` needs to be created for each of those users, so
  separate conversations can be held with different users starting from the same
  original `CodeCorps.Message`

  Once replies start coming in, a `CodeCorps.ConversationPart` is created for
  each of those replies.
  """
  use CodeCorps.Model

  @type t :: %__MODULE__{}

  schema "conversations" do
    field :status, :string, null: false, default: "open"
    field :read_at, :utc_datetime, null: true

    belongs_to :message, CodeCorps.Message
    belongs_to :user, CodeCorps.User

    has_many :conversation_parts, CodeCorps.ConversationPart

    timestamps()
  end
end
