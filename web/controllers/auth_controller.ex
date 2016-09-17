defmodule CodeCorps.AuthController do
  @analytics Application.get_env(:code_corps, :analytics)

  use CodeCorps.Web, :controller
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  alias CodeCorps.Repo
  alias CodeCorps.User

  def create(conn, params = %{"username" => _, "password" => _}) do
    case login_by_email_and_pass(params) do
      {:ok, user} ->
        {:ok, token, claims} = user |> Guardian.encode_and_sign(:token)

        conn
        |> Plug.Conn.assign(:current_user, user)
        |> @analytics.track(:signed_in)
        |> put_status(:created)
        |> render("show.json", token: token, user_id: user.id)

      {:error, error_message} ->
        conn
        |> put_status(:unauthorized)
        |> render("error.json", message: error_message)
    end
  end

  def delete(conn, _params) do
    {:ok, claims} = Guardian.Plug.claims(conn)

    conn
    |> Guardian.Plug.current_token
    |> Guardian.revoke!(claims)
    |> @analytics.track(:signed_out)

    conn
    |> render("delete.json")
  end

  defp login_by_email_and_pass(%{"username" => email, "password" => password}) do
    user = Repo.get_by(User, email: email)
    cond do
      user && checkpw(password, user.encrypted_password) ->
        {:ok, user}
      user ->
        {:error, "Your password doesn't match the email #{email}."}
      true ->
        dummy_checkpw()
        {:error, "We couldn't find a user with the email #{email}."}
    end
  end
end
