defmodule CodeCorps.SkillControllerTest do
  use CodeCorps.ConnCase

  alias CodeCorps.Skill
  alias CodeCorps.Repo

  @valid_attrs %{description: "Knowledge of the Elixir Language", original_row: 1, slug: "elixir-in-phoenix", title: "Elixir in Phoenix"}
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

  test "shows chosen resource", %{conn: conn} do
    skill = Repo.insert! %Skill{}
    conn = get conn, skill_path(conn, :show, skill)
    data = json_response(conn, 200)["data"]
    assert data["id"] == "#{skill.id}"
    assert data["type"] == "skill"
    assert data["attributes"]["title"] == skill.title
    assert data["attributes"]["description"] == skill.description
    assert data["attributes"]["original_row"] == skill.original_row
    assert data["attributes"]["slug"] == skill.slug
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
