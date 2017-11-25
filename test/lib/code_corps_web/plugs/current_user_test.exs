defmodule CodeCorpsWeb.Plug.CurrentUserTest do
  use CodeCorpsWeb.ConnCase

  test "sets conn.assigns[:current_user] if user is authenticated" do
    user = build(:user, first_name: "John");
    conn = CodeCorps.Guardian.Plug.put_current_resource(build_conn(), user)
    result_conn = CodeCorpsWeb.Plug.CurrentUser.call(conn, [])
    assert result_conn.assigns[:current_user] == user
  end

  test "simply returns conn if user is not authenticated" do
    conn = build_conn()
    result_conn = CodeCorpsWeb.Plug.CurrentUser.call(conn, [])
    assert result_conn == conn
    refute result_conn.assigns[:current_user]
  end
end
