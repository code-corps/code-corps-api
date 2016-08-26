defmodule CodeCorps.AuthenticationHelpers do
  use Phoenix.Controller
  import Plug.Conn, only: [halt: 1, put_status: 2]

  def handle_unauthorized(conn) do
    conn
    |> put_status(401)
    |> render(CodeCorps.AuthView, "error.json", message: "Not authorized")
    |> halt
  end

  def handle_not_found(conn) do
    conn
    |> put_status(:not_found)
    |> render(CodeCorps.ErrorView, "404.json")
    |> halt
  end
end
