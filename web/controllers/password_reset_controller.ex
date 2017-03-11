defmodule CodeCorps.PasswordResetController do
  use CodeCorps.Web, :controller

  alias CodeCorps.User

  def reset_password(conn, %{"value" => value, "password" => password, "password_confirmation" => password_confirmation}) do
    token = Repo.get_by(CodeCorps.AuthToken, value: value).value
    case Phoenix.Token.verify(CodeCorps.Endpoint, "user", token, max_age: 1209600) do
      {:ok, _} ->
        User.reset_password_changeset(conn.assigns.current_user, %{password: password, password_confirmation: password_confirmation})
        conn
        |> put_status(:created)
        |> render("show.json", token: token)
      {:error, _} ->
        {:error, conn}
    end
  end
end
