defmodule CodeCorps.AuthenticationHelpers do
  use Phoenix.Controller
  import Plug.Conn, only: [halt: 1, put_status: 2, assign: 3]

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

  def authorize(conn, changeset) do
    conn
    |> assign(:changeset, changeset)
    |> Canary.Plugs.authorize_resource(model: changeset)
  end

  def authorized?(conn), do: conn |> Map.get(:assigns) |> Map.get(:authorized)
end
