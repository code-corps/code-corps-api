defmodule CodeCorpsWeb.PreviewView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:markdown, :body, :inserted_at, :updated_at]

  has_one :user, type: "user", field: :user_id
end
