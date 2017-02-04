defmodule CodeCorps.TokenController do
  use CodeCorps.Web, :controller
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  alias CodeCorps.GuardianSerializer
  alias CodeCorps.Repo
  alias CodeCorps.User

  def create(conn, params = %{"username" => _, "password" => _}) do
    case login_by_email_and_pass(params) do
      {:ok, user} ->
        {:ok, token, _claims} = user |> Guardian.encode_and_sign(:token)

        conn
        |> Plug.Conn.assign(:current_user, user)
        |> put_status(:created)
        |> render("show.json", token: token, user_id: user.id)

      {:error, reason} -> handle_unauthenticated(conn, reason)
    end
  end
  def create(conn, %{"username" => ""}) do
    handle_unauthenticated(conn, "Please enter your email and password.")
  end
  def create(conn, %{"username" => _email}) do
    handle_unauthenticated(conn, "Please enter your password.")
  end

  def refresh(conn, %{"token" => current_token}) do
    with {:ok, claims} <- Guardian.decode_and_verify(current_token),
         {:ok, new_token, new_claims} <- Guardian.refresh!(current_token, claims, %{ttl: {30, :days}}),
         {:ok, user} <- GuardianSerializer.from_token(new_claims["sub"]) do
            conn
            |> Plug.Conn.assign(:current_user, user)
            |> put_status(:created)
            |> render("show.json", token: new_token, user_id: user.id)
    else
      {:error, reason} -> handle_unauthenticated(conn, reason)
    end
  end

  defp handle_unauthenticated(conn, reason) do
    conn
    |> put_status(:unauthorized)
    |> render("401.json", message: reason)
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
