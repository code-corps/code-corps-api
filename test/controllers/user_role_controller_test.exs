defmodule CodeCorps.UserRoleControllerTest do
  use CodeCorps.ConnCase

  alias CodeCorps.UserRole
  alias CodeCorps.Repo

  setup do
    conn =
      %{build_conn | host: "api."}
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  defp attributes do
    %{}
  end

  defp relationships(user, role) do
    %{
      user: %{data: %{id: user.id}},
      role: %{data: %{id: role.id}}
    }
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    user = insert(:user)
    role = insert(:role)

    conn = post conn, user_role_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "user-role",
        "attributes" => attributes,
        "relationships" => relationships(user, role)
      }
    }

    json = json_response(conn, 201)

    id = json["data"]["id"] |> String.to_integer
    user_role = UserRole |> Repo.get!(id)

    assert json["data"]["id"] == "#{user_role.id}"
    assert json["data"]["type"] == "user-role"
    assert json["data"]["relationships"]["user"]["data"]["id"] == "#{user.id}"
    assert json["data"]["relationships"]["role"]["data"]["id"] == "#{role.id}"
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_role_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "user-role",
        "attributes" => attributes,
      }
    }

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes resource", %{conn: conn} do
    role = insert(:role)
    user = insert(:user)
    user_role = insert(:user_role, user: user, role: role)
    response = delete conn, user_role_path(conn, :delete, user_role)

    assert response.status == 204
  end
end
