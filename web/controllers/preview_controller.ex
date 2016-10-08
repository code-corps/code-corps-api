defmodule CodeCorps.PreviewController do
  use CodeCorps.Web, :controller

  alias CodeCorps.Preview
  alias JaSerializer.Params

  plug :load_and_authorize_changeset, model: Preview, only: [:create]

  def create(conn, %{"data" => data = %{"type" => "preview", "attributes" => _preview_params}}) do
    changeset = Preview.create_changeset(%Preview{}, Params.to_attributes(data))

    case Repo.insert(changeset) do
      {:ok, preview} ->
        conn
        |> put_status(:created)
        |> render("show.json-api", data: preview)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end
end
