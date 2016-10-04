defmodule CodeCorps.PreviewController do
  use CodeCorps.Web, :controller
  alias CodeCorps.Preview
  alias JaSerializer.Params

  plug :load_and_authorize_resource, model: Preview, only: [:create]

  def create(conn, %{"data" => data = %{"type" => "preview", "attributes" => _project_params}}) do
    user =
      conn
      |> Guardian.Plug.current_resource

    changeset = Preview.changeset(%Preview{}, Params.to_attributes(data), user)



    case Repo.insert(changeset) do
      {:ok, preview} ->
        preview =
          preview
          |> Repo.preload([:user])

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
