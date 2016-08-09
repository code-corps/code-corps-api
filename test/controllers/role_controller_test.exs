defmodule CodeCorps.RoleControllerTest do
  use CodeCorps.ConnCase

  alias CodeCorps.Repo
  alias CodeCorps.Role

  @valid_attrs %{ability: "Backend Development", kind: "technology", name: "Backend Developer"}
  @invalid_attrs %{ability: "Juggling", kind: "circus", name: "Juggler"}

  setup do
    conn =
      %{build_conn | host: "api."}
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  defp relationships do
    %{}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, role_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, role_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "role",
        "attributes" => @valid_attrs,
        "relationships" => relationships
      }
    }

    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Role, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, role_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "role",
        "attributes" => @invalid_attrs,
        "relationships" => relationships
      }
    }

    assert json_response(conn, 422)["errors"] != %{}
  end
end
