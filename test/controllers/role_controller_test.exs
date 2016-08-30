defmodule CodeCorps.RoleControllerTest do
  use CodeCorps.ApiCase

  alias CodeCorps.Repo
  alias CodeCorps.Role

  @valid_attrs %{ability: "Backend Development", kind: "technology", name: "Backend Developer"}
  @invalid_attrs %{ability: "Juggling", kind: "circus", name: "Juggler"}

  defp build_payload, do: %{ "data" => %{"type" => "role"}}
  defp put_attributes(payload, attributes), do: payload |> put_in(["data", "attributes"], attributes)

  describe "index" do
    test "lists all entries on index", %{conn: conn} do
      path = conn |> role_path(:index)
      json = conn |> get(path) |> json_response(200)

      assert json["data"] == []
    end
  end

  describe "create" do
    @tag authenticated: :admin
    test "creates and renders resource when data is valid", %{conn: conn} do
      path = conn |> role_path(:create)
      payload = build_payload |> put_attributes(@valid_attrs)
      json = conn |> post(path, payload) |> json_response(201)

      assert json["data"]["id"]
      assert Repo.get_by(Role, @valid_attrs)
    end

    @tag authenticated: :admin
    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      path = conn |> role_path(:create)
      payload = build_payload |> put_attributes(@invalid_attrs)
      json = conn |> post(path, payload) |> json_response(422)

      assert json["errors"] != %{}
    end

    test "does not create resource and renders 401 when unauthenticated", %{conn: conn} do
      path = conn |> role_path(:create)
      payload = build_payload |> put_attributes(@valid_attrs)
      assert conn |> post(path, payload) |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 401 when not authorized", %{conn: conn} do
      path = conn |> role_path(:create)
      payload = build_payload |> put_attributes(@valid_attrs)
      assert conn |> post(path, payload) |> json_response(401)
    end
  end
end
