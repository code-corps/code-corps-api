defmodule CodeCorps.AuthControllerTest do
  use CodeCorps.ConnCase

  setup do
    conn =
      %{build_conn | host: "api."}
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  defp build_payload(email, password) do
    %{
      "username" => email,
      "password" => password
    }
  end

  test "authenticates and returns JWT and user ID when data is valid", %{conn: conn} do
    user = build(:user, %{password: "password"}) |> set_password("password") |> insert
    conn = post conn, auth_path(conn, :create), build_payload(user.email, user.password)

    response = json_response(conn, 201)
    assert response["token"]
    assert response["user_id"] == user.id
  end

  test "does not authenticate and renders errors when the password is wrong", %{conn: conn} do
    user = build(:user, %{password: "password"}) |> set_password("password") |> insert
    conn = post conn, auth_path(conn, :create), build_payload(user.email, "wrong password")

    response = json_response(conn, 401)
    [error | _] = response["errors"]
    assert error["detail"] == "Your password doesn't match the email #{user.email}."
    assert error["id"] == "UNAUTHORIZED"
    assert error["title"] == "401 Unauthorized"
    assert error["status"] == 401
    refute response["token"]
    refute response["user_id"]
  end

  test "does not authenticate and renders errors when the user doesn't exist", %{conn: conn} do
    conn = post conn, auth_path(conn, :create), build_payload("notauser@test.com", "password")

    response = json_response(conn, 401)
    [error | _] = response["errors"]
    assert error["detail"] == "We couldn't find a user with the email notauser@test.com."
    assert error["id"] == "UNAUTHORIZED"
    assert error["title"] == "401 Unauthorized"
    assert error["status"] == 401
    refute response["token"]
    refute response["user_id"]
  end
end
