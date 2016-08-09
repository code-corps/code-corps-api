defmodule CodeCorps.CategoryControllerTest do
  use CodeCorps.ConnCase

  alias CodeCorps.Category

  @valid_attrs %{description: "The technology category", name: "Technology", slug: "technology"}
  @invalid_attrs %{name: nil}

  setup do
    conn =
      %{build_conn | host: "api."}
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  defp build_payload(id, attributes, relationships \\ %{}) do
    build_payload(attributes)
    |> put_in(["data", "id"], id)
    |> put_in(["data", "relationships"], relationships)
  end

  defp build_payload(attributes) do
    %{
      "data" => %{
        "type" => "category",
        "attributes" => attributes
      }
    }
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, category_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    changeset = Category.changeset(%Category{}, @valid_attrs)
    category = Repo.insert!(changeset)
    conn = get conn, category_path(conn, :show, category)
    assert json_response(conn, 200)["data"] == %{
      "id" => "#{category.id}",
      "type" => "category",
      "attributes" => %{
        "name" => category.name,
        "slug" => category.slug,
        "description" => category.description
      }
    }
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, category_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, category_path(conn, :create), build_payload(@valid_attrs)
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Category, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, category_path(conn, :create), build_payload(@invalid_attrs)
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    changeset = Category.changeset(%Category{}, @valid_attrs)
    category = Repo.insert!(changeset)
    updated_attrs = %{@valid_attrs | description: "New Description"}
    conn = put conn, category_path(conn, :update, category), build_payload(category.id, updated_attrs)

    assert json_response(conn, 200)["data"]["id"] == "#{category.id}"
    assert Repo.get_by(Category, updated_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    changeset = Category.changeset(%Category{}, @valid_attrs)
    category = Repo.insert!(changeset)
    conn = put conn, category_path(conn, :update, category), build_payload(category.id, @invalid_attrs)
    assert json_response(conn, 422)["errors"] != %{}
  end
end
