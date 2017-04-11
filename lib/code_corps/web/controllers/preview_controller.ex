defmodule CodeCorps.Web.PreviewController do
  use CodeCorps.Web, :controller
  use JaResource

  alias CodeCorps.Web.Preview

  plug :load_and_authorize_changeset, model: Preview, only: [:create]
  plug JaResource

  def model(), do: Preview

  def handle_create(_conn, attributes) do
    Preview.create_changeset(%Preview{}, attributes)
  end
end
