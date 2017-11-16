defmodule CodeCorpsWeb.GithubEventView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [
    :action, :data, :event_type, :error, :failure_reason, :github_delivery_id,
    :inserted_at, :payload, :status, :updated_at
  ]

  def event_type(github_event, _conn) do
    github_event.type
  end
end
