defmodule CodeCorps.EndpointTest do
  use CodeCorps.ConnCase

  test "valid CORS request headers" do
    valid_cor_headers = ~w(origin accept x-requested-with content-type authorization)
    conn = build_conn(:options, "/")
     |> put_req_header("origin", "http://localhost:4200")
     |> put_req_header("access-control-request-method", "POST")
     |> put_req_header("access-control-request-headers", Enum.join(valid_cor_headers, ", "))
     |> options("/token")

    assert conn.status == 200
    assert get_resp_header(conn, "access-control-allow-origin") == ["http://localhost:4200"]
    assert get_resp_header(conn, "access-control-allow-methods") == ["HEAD, GET, POST, PUT, PATCH, DELETE"]
    assert get_resp_header(conn, "access-control-allow-headers") == ["accept, authorization, content-type, origin, x-requested-with"]
  end

  test "invalid CORS request headers" do
    invalid_cors_headers = ~w(x-foo x-bar)
    conn = build_conn(:options, "/")
     |> put_req_header("origin", "http://localhost:4200")
     |> put_req_header("access-control-request-method", "POST")
     |> put_req_header("access-control-request-headers", Enum.join(invalid_cors_headers, ", "))
     |> options("/token")

    assert conn.status == 200
    assert get_resp_header(conn, "access-control-allow-origin") == []
    assert get_resp_header(conn, "access-control-allow-methods") == []
    assert get_resp_header(conn, "access-control-allow-headers") == []
  end
end
