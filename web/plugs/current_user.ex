defmodule CodeCorps.Plug.CurrentUser do
  @moduledoc """
  Puts authenticated Guardian user into conn.assigns[:current_user]
  """

  @spec init(Keyword.t) :: Keyword.t
  def init(opts), do: opts

  @spec call(Plug.Conn.t, Keyword.t) :: Plug.Conn.t
  def call(conn, _opts) do
    case Guardian.Plug.current_resource(conn) do
      user = %CodeCorps.User{} ->
        Plug.Conn.assign(conn, :current_user, user)
      nil ->
        conn
    end
  end
end
