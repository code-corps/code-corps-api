defmodule CodeCorpsWeb.PreviewController do
  use CodeCorpsWeb, :controller
  use JaResource

  alias CodeCorps.Preview

  plug :load_and_authorize_changeset, model: Preview, only: [:create]
  plug JaResource

  @spec model :: module
  def model, do: CodeCorps.Preview

  def handle_create(_conn, attributes) do
    Preview.create_changeset(%Preview{}, attributes)
  end
end
