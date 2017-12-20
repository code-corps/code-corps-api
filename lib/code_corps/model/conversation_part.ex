defmodule CodeCorps.ConversationPart do
  @moduledoc ~S"""
  An individual "line of conversation" in a `CodeCorps.Conversation` thread,
  depicting a reply to the `CodeCorps.Conversation` by any of the two sides.

  When a project sends a `CodeCorps.Message` to one or more users, a
  `CodeCorps.Conversation` needs to be created for each of those users, so
  separate conversations can be held with different users starting from the same
  original `CodeCorps.Message`

  Once replies start coming in, a `CodeCorps.ConversationPart` is created for
  each of those replies, regardless of which side is making them.
  """

  use CodeCorps.Model

  @type t :: %__MODULE__{}

  schema "conversation_parts" do
    field :body, :string, null: false
    field :read_at, :utc_datetime, null: true
    field :part_type, :string, default: "comment"

    belongs_to :author, CodeCorps.User
    belongs_to :conversation, CodeCorps.Conversation

    timestamps()
  end
end
