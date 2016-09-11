defmodule CodeCorps.Plug.CurrentUser do
  alias CodeCorps.GuardianSerializer

  def init(opts), do: opts

  def call(conn, _opts) do
    current_token = Guardian.Plug.current_token(conn)
    case Guardian.decode_and_verify(current_token) do
      {:ok, claims} ->
        case GuardianSerializer.from_token(claims["sub"]) do
          {:ok, user} ->
            Plug.Conn.assign(conn, :current_user, user)
          {:error, _reason} ->
            conn
        end
      {:error, _reason} ->
        conn
    end
  end
end
