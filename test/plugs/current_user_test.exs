defmodule CodeCorps.Plug.CurrentUserTest do

  use CodeCorps.ConnCase

  test "sets conn.assigns[:current_user] if user is authenticated" do
    user = build(:user, first_name: "John");
    conn = Guardian.Plug.set_current_resource(
      build_conn(),
      user
    )
    result_conn = CodeCorps.Plug.CurrentUser.call(conn, [])
    assert result_conn.assigns[:current_user] == user
  end

  test "simply returns conn if user is not authenticated" do
    conn = build_conn()
    result_conn = CodeCorps.Plug.CurrentUser.call(conn, [])
    assert result_conn == conn
  end
end
