defmodule CodeCorps.ProjectUserController do
  use CodeCorps.Web, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.{Emails, Mailer, ProjectUser}

  @preloads [:project, :user]

  plug :load_resource, model: ProjectUser, only: [:show], preload: @preloads
  plug :load_and_authorize_resource, model: ProjectUser, only: [:delete]
  plug :load_and_authorize_changeset, model: ProjectUser, only: [:create, :update], preload: @preloads
  plug :schedule_email when action in [:update]
  plug JaResource


  @spec filter(Plug.Conn.t, Ecto.Query.t, String.t, String.t) :: Ecto.Query.t
  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

  @spec handle_create(Plug.Conn.t, map) :: Ecto.Changeset.t
  def handle_create(_conn, attributes) do
    %ProjectUser{} |> ProjectUser.create_changeset(attributes)
  end

  @spec handle_update(Plug.Conn.t, ProjectUser.t, map) :: Ecto.Changeset.t
  def handle_update(_conn, model, attributes) do
    model |> ProjectUser.update_changeset(attributes)
  end

  defp schedule_email(conn, _) do
    conn
    |> Plug.Conn.register_before_send(&maybe_send_email/1)
  end

  defp maybe_send_email(%{assigns: %{ changeset: changeset}} = conn) do
    case {changeset |> Ecto.Changeset.get_change(:role), changeset.data.role} do
      {"contributor", "pending"} -> send_acceptance_email(conn.assigns.project_user)
      _ -> nil
    end

    conn
  end
  defp maybe_send_email(conn), do: conn

  defp send_acceptance_email(project_user) do
    project_user
    |> Emails.ProjectUserAcceptanceEmail.create()
    |> Mailer.deliver_now()
  end
end
