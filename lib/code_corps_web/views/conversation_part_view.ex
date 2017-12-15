defmodule CodeCorpsWeb.ConversationPartView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:body, :inserted_at, :read_at, :updated_at]

  has_one :author, type: "user", field: :author_id
  has_one :conversation, type: "conversation", field: :conversation_id
end
