defmodule CodeCorps.AuthenticationTestHelpers do
  use Phoenix.ConnTest
  import CodeCorps.Factories

  def authenticate(conn) do
    user = insert(:user)

    conn
    |> authenticate(user)
  end

  def authenticate(conn, user) do
    {:ok, jwt, _} = Guardian.encode_and_sign(user)

    conn
    |> put_req_header("authorization", "Bearer #{jwt}")
  end
end
