defmodule CodeCorpsWeb.ProjectUserController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{
    Analytics.SegmentTracker,
    Analytics.SegmentDataExtractor,
    Emails,
    Helpers.Query,
    Mailer,
    ProjectUser,
    User
  }

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @preloads [:project, :user]

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with project_users <- ProjectUser |> Query.id_filter(params) |> Repo.all do
      conn |> render("index.json-api", data: project_users)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %ProjectUser{} = project_user <- ProjectUser |> Repo.get(id) |> Repo.preload(@preloads) do
      conn |> render("show.json-api", data: project_user)
    end
  end

  @spec create(Plug.Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %ProjectUser{}, params),
         {:ok, %ProjectUser{} = project_user} <- %ProjectUser{} |> ProjectUser.create_changeset(params) |> Repo.insert,
         _ <- maybe_send_create_email(project_user)
    do
      track_created(current_user, project_user)
      conn |> put_status(:created) |> render("show.json-api", data: project_user)
    end
  end

  @spec update(Conn.t, map) :: Conn.t
  def update(%Conn{} = conn, %{"id" => id} = params) do
    with %ProjectUser{} = project_user <- ProjectUser |> Repo.get(id),
         %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:update, project_user, params),
         {:ok, %ProjectUser{} = updated_project_user} <- project_user |> ProjectUser.update_changeset(params) |> Repo.update,
         _ <- maybe_send_update_email(updated_project_user, project_user)
    do
      track_updated(current_user, project_user)
      conn |> render("show.json-api", data: updated_project_user)
    end
  end

  @spec delete(Conn.t, map) :: Conn.t
  def delete(%Conn{} = conn, %{"id" => id} = _params) do
    with %ProjectUser{} = project_user <- ProjectUser |> Repo.get(id),
         %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:delete, project_user),
         {:ok, %ProjectUser{} = _project_user} <- project_user |> Repo.delete
    do
      conn |> send_resp(:no_content, "")
    end
  end

  @spec maybe_send_create_email(ProjectUser.t) :: Bamboo.Email.t | nil
  defp maybe_send_create_email(%ProjectUser{role: "pending"} = project_user) do
    send_request_email(project_user)
  end
  defp maybe_send_create_email(_), do: nil

  @spec send_request_email(ProjectUser.t) :: Bamboo.Email.t
  defp send_request_email(project_user) do
    project_user
    |> Repo.preload(@preloads)
    |> Emails.ProjectUserRequestEmail.create()
    |> Mailer.deliver_now()
  end

  @spec maybe_send_update_email(ProjectUser.t, ProjectUser.t) :: Bamboo.Email.t | nil
  defp maybe_send_update_email(%ProjectUser{role: updated_role} = project_user, %ProjectUser{role: previous_role}) do
    case {updated_role, previous_role} do
      {"contributor", "pending"} ->
        send_acceptance_email(project_user)
      _ -> nil
    end
  end

  @spec send_acceptance_email(ProjectUser.t) :: Bamboo.Email.t
  defp send_acceptance_email(project_user) do
    project_user
    |> Repo.preload(@preloads)
    |> Emails.ProjectUserAcceptanceEmail.create()
    |> Mailer.deliver_now()
  end

  @spec track_created(User.t, ProjectUser.t) :: any
  def track_created(
    %User{id: user_id},
    %ProjectUser{} = project_user) do

    SegmentTracker.track(user_id, "Requested Membership (User)", project_user)

    project_user 
    |> SegmentDataExtractor.get_project_id()
    |> SegmentTracker.track("Membership Requested (Project)", project_user)
  end

  @spec track_updated(User.t, ProjectUser.t) :: any
  def track_updated(
    %User{id: user_id} = user,
    %ProjectUser{} = project_user) do

    data = %{
      current_user: user,
      project_user: project_user
    }

    SegmentTracker.track(user_id, "Membership Approved (User)", data)

    project_user
    |> SegmentDataExtractor.get_project_id()
    |> SegmentTracker.track("Approved Membership (Project)", data)
  end
end
