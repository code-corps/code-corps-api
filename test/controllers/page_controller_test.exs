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

  test "allows CORS for valid access control request headers" do
    valid_cor_headers = ~w(origin accept x-requested-with content-type authorization)
    conn = build_conn()
     |> put_req_header("origin", "http://localhost:4200")
     |> put_req_header("access-control-request-method", "GET")
     |> put_req_header("access-control-request-headers", Enum.join(valid_cor_headers, ", "))
     |> options("/")

    assert conn.status == 200
    assert get_resp_header(conn, "access-control-allow-origin") == ["http://localhost:4200"]
    assert get_resp_header(conn, "access-control-allow-methods") == ["HEAD, GET, POST, PUT, PATCH, DELETE"]
    assert get_resp_header(conn, "access-control-allow-headers") == ["accept, authorization, content-type, origin, x-requested-with"]
  end

  test "does not allow CORS for invalid access control request headers" do
    invalid_cors_headers = ~w(x-foo x-bar)
    conn = build_conn()
     |> put_req_header("origin", "http://localhost:4200")
     |> put_req_header("access-control-request-method", "GET")
     |> put_req_header("access-control-request-headers", Enum.join(invalid_cors_headers, ", "))
     |> options("/")

    assert conn.status == 200
    assert get_resp_header(conn, "access-control-allow-origin") |> Enum.empty?
    assert get_resp_header(conn, "access-control-allow-methods") |> Enum.empty?
    assert get_resp_header(conn, "access-control-allow-headers") |> Enum.empty?
  end
end
