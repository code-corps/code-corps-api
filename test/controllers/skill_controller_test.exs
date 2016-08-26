defmodule CodeCorps.SkillControllerTest do
  use CodeCorps.ConnCase

  alias CodeCorps.Skill
  alias CodeCorps.Repo

  @valid_attrs %{
    description: "Elixir is a functional, concurrent, general-purpose programming language that runs on the Erlang virtual machine (BEAM).",
    original_row: 1,
    title: "Elixir"
  }
  @invalid_attrs %{}

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
    conn = get conn, skill_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "filters resources on index", %{conn: conn} do
    elixir = insert(:skill, title: "Elixir")
    phoenix = insert(:skill, title: "Phoenix")
    insert(:skill, title: "Rails")
    params = %{"filter" => %{"id" => "#{elixir.id},#{phoenix.id}"}}
    path = conn |> skill_path(:index, params)
    data = conn |> get(URI.decode(path)) |> json_response(200) |> Map.get("data")
    assert data |> length == 2

    [first_result, second_result | _] = data
    assert first_result["id"] == "#{elixir.id}"
    assert second_result["id"] == "#{phoenix.id}"
  end

  test "returns search results on index", %{conn: conn} do
    ruby = insert(:skill, title: "Ruby")
    rails = insert(:skill, title: "Rails")
    insert(:skill, title: "Phoenix")
    params = %{"query" => "r"}
    conn = get conn, skill_path(conn, :index, params)
    data = json_response(conn, 200)["data"]
    [first_result, second_result | _] = data
    assert length(data) == 2
    assert first_result["id"] == "#{ruby.id}"
    assert second_result["id"] == "#{rails.id}"
  end

  test "shows chosen resource", %{conn: conn} do
    skill = insert(:skill)
    conn = get conn, skill_path(conn, :show, skill)
    data = json_response(conn, 200)["data"]
    assert data["id"] == "#{skill.id}"
    assert data["type"] == "skill"
    assert data["attributes"]["title"] == skill.title
    assert data["attributes"]["description"] == skill.description
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, skill_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, skill_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "skill",
        "attributes" => @valid_attrs,
        "relationships" => relationships
      }
    }

    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Skill, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, skill_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "skill",
        "attributes" => @invalid_attrs,
        "relationships" => relationships
      }
    }

    assert json_response(conn, 422)["errors"] != %{}
  end
end
