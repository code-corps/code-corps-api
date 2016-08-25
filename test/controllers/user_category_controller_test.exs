defmodule CodeCorps.UserCategoryControllerTest do
  use CodeCorps.ConnCase

  alias CodeCorps.Repo
  alias CodeCorps.UserCategory

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

  defp relationships(user, category) do
    %{
      user: %{data: %{id: user.id}},
      category: %{data: %{id: category.id}}
    }
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, user_category_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "filters resources on index", %{conn: conn} do
    society = insert(:category, name: "Society")
    technology = insert(:category, name: "Technology")
    government = insert(:category, name: "Government")

    user = insert(:user)
    user_category_1 = insert(:user_category, user: user, category: society)
    user_category_2 = insert(:user_category, user: user, category: technology)
    insert(:user_category, user: user, category: government)

    conn = get conn, "user-categories/?filter[id]=#{user_category_1.id},#{user_category_2.id}"
    data = json_response(conn, 200)["data"]
    [first_result, second_result | _] = data
    assert length(data) == 2
    assert first_result["id"] == "#{user_category_1.id}"
    assert second_result["id"] == "#{user_category_2.id}"
  end

  test "shows chosen resource", %{conn: conn} do
    category = insert(:category)
    user = insert(:user)
    user_category = insert(:user_category, user: user, category: category)
    conn = get conn, user_category_path(conn, :show, user_category)
    data = json_response(conn, 200)["data"]
    assert data["id"] == "#{user_category.id}"
    assert data["type"] == "user-category"
    assert data["relationships"]["user"]["data"]["id"] == "#{user.id}"
    assert data["relationships"]["category"]["data"]["id"] == "#{category.id}"
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, user_category_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    user = insert(:user)
    category = insert(:category, %{name: "test-category"})

    conn = post conn, user_category_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "user-category",
        "attributes" => attributes,
        "relationships" => relationships(user, category)
      }
    }

    json = json_response(conn, 201)

    id = json["data"]["id"] |> String.to_integer
    user_category = UserCategory |> Repo.get!(id)

    assert json["data"]["id"] == "#{user_category.id}"
    assert json["data"]["type"] == "user-category"
    assert json["data"]["relationships"]["user"]["data"]["id"] == "#{user.id}"
    assert json["data"]["relationships"]["category"]["data"]["id"] == "#{category.id}"
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_category_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "user-category",
        "attributes" => attributes,
      }
    }

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes resource", %{conn: conn} do
    category = insert(:category, %{name: "test-category"})
    user = insert(:user)
    user_category = insert(:user_category, user: user, category: category)
    response = delete conn, user_category_path(conn, :delete, user_category)

    assert response.status == 204
  end
end
