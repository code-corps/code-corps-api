defmodule CodeCorps.Web.PasswordResetController do
  use CodeCorps.Web, :controller

  alias CodeCorps.Web.{User, AuthToken, ErrorView}
  alias Ecto.Changeset

  @doc"""
  reset_password should take a token, password, and password_confirmation and check
  1. the token exists in AuthToken model & verifies it with Phoenix.Token.verify
  2. password & password_confirmation match
  and return email. 422 if pwd do not match or auth token does not exist
  """
  def reset_password(conn, %{"token" => token, "password" => password, "password_confirmation" => password_confirmation}) do
    user = conn.assigns.current_user
    with %AuthToken{value: auth_token} <- Repo.get_by(AuthToken, %{ value: token, user_id: user.id }),
      {:ok, _} <- Phoenix.Token.verify(CodeCorps.Web.Endpoint, "user", auth_token, max_age: 1209600) do
        with %Changeset{valid?: true} <- User.reset_password_changeset(user,
                                                                       %{password: password, password_confirmation: password_confirmation}) do
          conn
          |> put_status(:created)
          |> render("show.json", email: user.email)
        else
          %Changeset{valid?: false} ->
            handle_reset_pswd_result(conn)
        end
    else
      nil ->
        handle_reset_pswd_result(conn)
    end
  end

  defp handle_reset_pswd_result(conn) do
    conn
    |> put_status(422)
    |> render(ErrorView, "422.json-api")
  end

end
