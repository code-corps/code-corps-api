defmodule CodeCorps.UserController do
  use CodeCorps.Web, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.User
  alias CodeCorps.Services.UserService

  plug :load_and_authorize_resource, model: User, only: [:update]
  plug JaResource

  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

  def handle_create(conn, attributes) do
    with {:ok, user} <- %User{} |> User.registration_changeset(attributes) |> Repo.insert,
         conn        <- login(user, conn)
    do
      CodeCorps.Analytics.Segment.track({:ok, user}, :signed_up, conn)
    else
      {:error, changeset} -> changeset
    end
  end

  defp login(user, conn), do: Plug.Conn.assign(conn, :current_user, user)

  def handle_update(conn, record, attributes) do
    with {:ok, user, _, _} <- UserService.update(record, attributes)
    do
      {:ok, user} |> CodeCorps.Analytics.Segment.track(:updated_profile, conn)
    else
      {:error, changeset} -> changeset
    end
  end

  def email_available(conn, %{"email" => email}) do
    hash = User.check_email_availability(email)
    conn |> json(hash)
  end

  def username_available(conn, %{"username" => username}) do
    hash = User.check_username_availability(username)
    conn |> json(hash)
  end
end
