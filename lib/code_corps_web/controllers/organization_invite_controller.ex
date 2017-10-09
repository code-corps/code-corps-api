defmodule CodeCorpsWeb.OrganizationInviteController do
  use CodeCorpsWeb, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2]
  alias CodeCorps.{Emails, Mailer, OrganizationInvite}

  plug :load_and_authorize_resource, model: OrganizationInvite, only: [:create, :update]
  plug JaResource

  @spec model :: module
  def model, do: CodeCorps.OrganizationInvite

  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

  def handle_create(_conn, attributes) do
    OrganizationInvite.create_changeset(%OrganizationInvite{}, attributes)
  end

  def render_create(conn, model) do
    send_email(model)
    conn
    |> put_status(:created)
    |> Phoenix.Controller.render(:show, data: model)
  end

  defp send_email(organization_invite) do
    organization_invite
    |> Emails.OrganizationInviteEmail.create()
    |> Mailer.deliver_later()
  end
end