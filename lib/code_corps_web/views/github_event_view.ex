defmodule CodeCorpsWeb.GithubEventView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [
    :action, :event_type, :error, :failure_reason, :github_delivery_id,
    :inserted_at, :payload, :record_data, :status, :updated_at
  ]

  def event_type(github_event, _conn) do
    github_event.type
  end

  def record_data(github_event, _conn) do
    github_event.data
  end
end
