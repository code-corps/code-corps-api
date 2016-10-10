defmodule CodeCorps.OrganizationController do
  use CodeCorps.Web, :controller
  import CodeCorps.Organization, only: [changeset: 2]
  alias CodeCorps.Organization
  alias JaSerializer.Params

  plug :load_and_authorize_resource, model: Organization, only: [:create, :update]
  plug :scrub_params, "data" when action in [:create, :update]

  def index(conn, params) do
    organizations =
      Organization
      |> Organization.index_filters(params)
      |> Repo.all

    render(conn, "index.json-api", data: organizations)
  end

  def create(conn, %{"data" => data = %{"type" => "organization", "attributes" => _organization_params}}) do
    changeset = Organization.create_changeset(%Organization{}, Params.to_attributes(data))

    case Repo.insert(changeset) do
      {:ok, organization} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", organization_path(conn, :show, organization))
        |> render("show.json-api", data: organization)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    organization =
      Organization
      |> Repo.get!(id)
    render(conn, "show.json-api", data: organization)
  end

  def update(conn, %{"id" => id, "data" => data = %{"type" => "organization", "attributes" => _organization_params}}) do
    changeset =
      Organization
      |> Repo.get!(id)
      |> changeset(Params.to_attributes(data))

    case Repo.update(changeset) do
      {:ok, organization} ->
        render(conn, "show.json-api", data: organization)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end
end
