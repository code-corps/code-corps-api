defmodule CodeCorps.OrganizationMembershipController do
  @analytics Application.get_env(:code_corps, :analytics)

  use CodeCorps.Web, :controller

  alias CodeCorps.OrganizationMembership

  plug :load_resource, model: OrganizationMembership, only: [:show], preload: [:organization, :member]
  plug :load_and_authorize_resource, model: OrganizationMembership, only: [:delete]
  plug :load_and_authorize_changeset, model: OrganizationMembership, only: [:create, :update], preload: [:organization, :member]

  plug :scrub_params, "data" when action in [:create, :update]

  def index(conn, params) do
    memberships =
      OrganizationMembership
      |> OrganizationMembership.index_filters(params)
      |> Repo.all

    render(conn, "index.json-api", data: memberships)
  end

  def show(conn, %{"id" => _id}) do
    render(conn, "show.json-api", data: conn.assigns.organization_membership)
  end

  def create(conn, %{"data" => %{"type" => "organization-membership"}}) do
    case Repo.insert(conn.assigns.changeset) do
      {:ok, membership} ->
        conn
        |> @analytics.track(:created, membership)
        |> put_status(:created)
        |> put_resp_header("location", organization_membership_path(conn, :show, membership))
        |> render("show.json-api", data: membership)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end

  def update(conn, %{"id" => _id, "data" => %{"type" => "organization-membership", "attributes" => _params}}) do
    case Repo.update(conn.assigns.changeset) do
      {:ok, membership} ->
        render(conn, "show.json-api", data: membership)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => _id}) do
    conn.assigns.organization_membership |> Repo.delete!
    conn |> send_resp(:no_content, "")
  end
end
