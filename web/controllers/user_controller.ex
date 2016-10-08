defmodule CodeCorps.UserController do
  use CodeCorps.Web, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.User

  plug :load_and_authorize_resource, model: User, only: [:update]
  plug JaResource

  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

  def handle_create(conn, attributes) do
    %User{}
    |> User.registration_changeset(attributes)
    |> Repo.insert
    |> login(conn)
    |> track_signup
  end

  defp login({:error, changeset}, conn), do: {:error, changeset, conn}
  defp login({:ok, model}, conn) do
    {:ok, model, conn |> Plug.Conn.assign(:current_user, model)}
  end

  defp track_signup({status, model_or_changeset, conn}) do
    CodeCorps.Analytics.Segment.track({status, model_or_changeset}, :signed_up, conn)
  end

  def handle_update(conn, model, attributes) do
    model
    |> User.update_changeset(attributes)
    |> Repo.update
    |> CodeCorps.Analytics.Segment.track(:updated_profile, conn)
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
