defmodule CodeCorps.PreviewController do
  use CodeCorps.Web, :controller
  use JaResource

  alias CodeCorps.Preview

  plug :load_and_authorize_changeset, model: Preview, only: [:create]
  plug JaResource

  def handle_create(_conn, attributes) do
    Preview.create_changeset(%Preview{}, attributes)
  end
end
