defmodule CodeCorps.Web.UserController do
  use CodeCorps.Web, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2, user_filter: 2, limit_filter: 2]

  alias CodeCorps.Web.User
  alias CodeCorps.Services.UserService

  plug :load_and_authorize_resource, model: User, only: [:update]
  plug JaResource
  plug :login, only: [:create]

  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

  def handle_index(_conn, params) do
    User
    |> user_filter(params)
    |> limit_filter(params)
  end

  def handle_create(_conn, attributes) do
    %User{} |> User.registration_changeset(attributes)
  end

  def handle_update(_conn, record, attributes) do
    with {:ok, user, _, _} <- UserService.update(record, attributes)
    do
      {:ok, user}
    else
      {:error, changeset} -> {:error, changeset}
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

  defp login(conn, _opts) do
    Plug.Conn.register_before_send(conn, &do_login(&1))
  end

  defp do_login(conn), do: Plug.Conn.assign(conn, :current_user, conn.assigns[:data])
end
