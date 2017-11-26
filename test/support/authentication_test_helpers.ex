defmodule CodeCorps.AuthenticationTestHelpers do
  use Phoenix.ConnTest
  import CodeCorps.Factories

  def authenticate(conn) do
    user = insert(:user)

    conn
    |> authenticate(user)
  end

  def authenticate(conn, user) do
    {:ok, token, _} = user |> CodeCorps.Guardian.encode_and_sign()

    conn
    |> put_req_header("authorization", "Bearer #{token}")
  end
end
