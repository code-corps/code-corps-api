defmodule CodeCorps.PageControllerTest do
  use CodeCorps.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert redirected_to(conn, 302) =~ "http://docs.codecorpsapi.apiary.io/"
  end

  test "allows CORS from http://localhost:4200" do
    conn = build_conn()
      |> put_req_header("origin", "http://localhost:4200")
      |> get("/")

    assert "http://localhost:4200" in get_resp_header(conn, "access-control-allow-origin")
  end

  test "does not allow CORS for http://google.com" do
    conn = build_conn()
      |> put_req_header("origin", "http://google.com")
      |> get("/")

    refute "http://google.com" in get_resp_header(conn, "access-control-allow-origin")
  end
end
