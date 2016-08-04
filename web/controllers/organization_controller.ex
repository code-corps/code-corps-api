defmodule CodeCorps.OrganizationController do
  use CodeCorps.Web, :controller

  alias CodeCorps.Organization
  alias JaSerializer.Params

  import Organization, only: [changeset: 2]

  plug :scrub_params, "data" when action in [:create, :update]

  def index(conn, _params) do
    organizations =
      Organization
      |> preload([:slugged_route])
      |> Repo.all
    render(conn, "index.json-api", data: organizations)
  end

  def create(conn, %{"data" => data = %{"type" => "organization", "attributes" => _organization_params}}) do
    changeset = Organization.create_changeset(%Organization{}, Params.to_attributes(data))

    case Repo.insert(changeset) do
      {:ok, organization} ->
        organization = Repo.preload(organization, [:slugged_route])

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
      |> preload([:slugged_route])
      |> Repo.get!(id)
    render(conn, "show.json-api", data: organization)
  end

  def update(conn, %{"id" => id, "data" => data = %{"type" => "organization", "attributes" => _organization_params}}) do
    changeset =
      Organization
      |> preload([:slugged_route])
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
