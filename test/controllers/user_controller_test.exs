defmodule CodeCorps.UserControllerTest do
  use CodeCorps.ApiCase

  alias CodeCorps.User
  alias CodeCorps.Repo
  alias CodeCorps.SluggedRoute

  @valid_attrs %{
    email: "test@user.com",
    username: "testuser",
    first_name: "Test",
    last_name: "User",
    website: "http://www.example.com",
    twitter: "testuser",
    biography: "Just a test user"
  }

  @invalid_attrs %{
    email: "",
    username: "",
    website: "---_<>-blank.com",
    twitter: " @ testuser"
  }

  defp relationships do
    %{}
  end

  describe "index" do

    test "lists all entries on index", %{conn: conn} do
      conn = get conn, user_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end

    test "filters resources on index", %{conn: conn} do
      user_1 = insert(:user, username: "user_1", email: "user_1@mail.com")
      user_2 = insert(:user, username: "user_2", email: "user_2@mail.com")
      insert(:user, username: "user_3", email: "user_3@mail.com")
      conn = get conn, "users/?filter[id]=#{user_1.id},#{user_2.id}"
      data = json_response(conn, 200)["data"]
      [first_result, second_result | _] = data
      assert length(data) == 2
      assert first_result["id"] == "#{user_1.id}"
      assert second_result["id"] == "#{user_2.id}"
    end
  end

  describe "#show" do

    test "shows chosen resource", %{conn: conn} do
      user = insert(:user)
      conn = get conn, user_path(conn, :show, user)
      data = json_response(conn, 200)["data"]
      assert data["id"] == "#{user.id}"
      assert data["type"] == "user"
      assert data["attributes"]["username"] == user.username
      assert data["attributes"]["email"] == user.email
      assert data["attributes"]["password"] == nil
    end

    test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
      assert_error_sent 404, fn ->
        get conn, user_path(conn, :show, -1)
      end
    end
  end

  describe "create" do
    test "creates and renders resource when data is valid", %{conn: conn} do
      attrs = Map.put(@valid_attrs, :password, "password")
      conn = post conn, user_path(conn, :create), %{
        "meta" => %{},
        "data" => %{
          "type" => "user",
          "attributes" => attrs,
          "relationships" => relationships
        }
      }

      id = json_response(conn, 201)["data"]["id"]
      assert id
      user = Repo.get(User, id)
      assert user
      slugged_route = Repo.get_by(SluggedRoute, slug: "testuser")
      assert slugged_route
      assert user.id == slugged_route.user_id
    end

    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      conn = post conn, user_path(conn, :create), %{
        "meta" => %{},
        "data" => %{
          "type" => "user",
          "attributes" => @invalid_attrs,
          "relationships" => relationships
        }
      }

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update" do
    test "updates and renders chosen resource when data is valid", %{conn: conn} do
      user = insert(:user)
      attrs = Map.put(@valid_attrs, :password, "password")

      params = %{
        "meta" => %{},
        "data" => %{
          "type" => "user",
          "id" => user.id,
          "attributes" => attrs,
          "relationships" => relationships
        }
      }

      path = user_path(conn, :update, user)

      conn =
        conn
        |> authenticate(user)
        |> put(path, params)

      id = json_response(conn, 200)["data"]["id"]
      assert id
      user =  Repo.get(User, id)
      assert user.email == "test@user.com"
      assert user.first_name == "Test"
      assert user.last_name == "User"
      assert user.website == "http://www.example.com"
      assert user.biography == "Just a test user"
    end

    test "does not update when authorized as different user", %{conn: conn} do
      user = insert(:user)
      another_user = insert(:user)

      attrs = Map.put(@valid_attrs, :password, "password")

      path = user_path(conn, :update, user)

      params = %{
        "meta" => %{},
        "data" => %{
          "type" => "user",
          "id" => user.id,
          "attributes" => attrs,
          "relationships" => relationships
        }
      }

      conn =
        conn
        |> authenticate(another_user)
        |> put(path, params)

      assert json_response(conn, 401)
    end

    @tag :requires_env
    test "uploads a photo to S3", %{conn: conn} do
      user = insert(:user)
      photo_data = "data:image/gif;base64,R0lGODlhAQABAIAAAAUEBAAAACwAAAAAAQABAAACAkQBADs="
      attrs = Map.put(@valid_attrs, :base64_photo_data, photo_data)
      conn = put conn, user_path(conn, :update, user), %{
        "meta" => %{},
        "data" => %{
          "type" => "user",
          "id" => user.id,
          "attributes" => attrs,
          "relationships" => relationships
        }
      }

      data = json_response(conn, 200)["data"]
      large_url = data["attributes"]["photo-large-url"]
      assert String.contains? large_url, "/users/#{user.id}/large"
      thumb_url = data["attributes"]["photo-thumb-url"]
      assert String.contains? thumb_url, "/users/#{user.id}/thumb"
    end

    test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
      user = insert(:user)

      path = user_path(conn, :update, user)

      params = %{
        "meta" => %{},
        "data" => %{
          "type" => "user",
          "id" => user.id,
          "attributes" => @invalid_attrs,
          "relationships" => relationships
        }
      }
      conn =
        conn
        |> authenticate(user)
        |> put(path, params)

      json =  json_response(conn, 422)
      assert json["errors"] != %{}
      errors = json["errors"]
      assert errors["email"] == ["can't be blank"]
      assert errors["twitter"] == ["has invalid format"]
      assert errors["website"] == ["has invalid format"]
    end
  end

  describe "email_available" do
    test "returns valid and available when email is valid and available", %{conn: conn} do
      resp = get conn, user_path(conn, :email_available, %{email: "available@mail.com"})
      json = json_response(resp, 200)
      assert json["available"]
      assert json["valid"]

    end

    test "returns valid but inavailable when email is valid but taken", %{conn: conn} do
      insert(:user, email: "used@mail.com")
      resp = get conn, user_path(conn, :email_available, %{email: "used@mail.com"})
      json = json_response(resp, 200)
      refute json["available"]
      assert json["valid"]
    end

    test "returns as available but invalid when email is invalid", %{conn: conn} do
      resp = get conn, user_path(conn, :email_available, %{email: "not_an_email"})
      json = json_response(resp, 200)
      assert json["available"]
      refute json["valid"]
    end
  end

  describe "username_available" do
    test "returns as valid and available when username is valid and available", %{conn: conn} do
      resp = get conn, user_path(conn, :username_available, %{username: "available"})
      json = json_response(resp, 200)
      assert json["available"]
      assert json["valid"]
    end

    test "returns as valid, but inavailable when username is valid but taken", %{conn: conn} do
      insert(:user, username: "used")
      resp = get conn, user_path(conn, :username_available, %{username: "used"})
      json = json_response(resp, 200)
      refute json["available"]
      assert json["valid"]
    end

    test "returns available but invalid when username is invalid", %{conn: conn} do
      resp = get conn, user_path(conn, :username_available, %{username: ""})
      json = json_response(resp, 200)
      assert json["available"]
      refute json["valid"]
    end
  end
end
