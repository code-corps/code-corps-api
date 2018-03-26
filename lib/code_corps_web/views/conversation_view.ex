defmodule CodeCorpsWeb.ConversationView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:read_at, :status, :inserted_at, :updated_at]

  has_one :user, type: "user", field: :user_id
  has_one :message, type: "message", field: :message_id

  has_many :conversation_parts, serializer: CodeCorpsWeb.ConversationPartView, include: false, identifiers: :when_included
end
