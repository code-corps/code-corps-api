defmodule CodeCorps.Auth.ErrorHandler do
  use CodeCorpsWeb, :controller

  def auth_error(conn, {type, _reason}, _opts) do
    conn
    |> put_status(401)
    |> render(CodeCorpsWeb.TokenView, "401.json", message: to_string(type))
  end
end
