defmodule CodeCorpsWeb.UserControllerTest do
  @moduledoc false

  use CodeCorpsWeb.ApiCase, resource_name: :user

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{User, Repo}

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

  @relationships %{}

  describe "index" do
    test "lists all entries on index", %{conn: conn} do
      [user_1, user_2] = insert_pair(:user)

      conn
      |> request_index
      |> json_response(200)
      |> assert_ids_from_response([user_1.id, user_2.id])
    end

    test "filters resources on index", %{conn: conn} do
      [user_1, user_2 | _] = insert_list(3, :user)

      path = "users/?filter[id]=#{user_1.id},#{user_2.id}"

      conn
      |> get(path)
      |> json_response(200)
      |> assert_ids_from_response([user_1.id, user_2.id])
    end

    test "returns search results on index", %{conn: conn} do
      user_1 = insert(:user, first_name: "Joe")
      user_2 = insert(:user, username: "joecoder")
      user_3 = insert(:user, last_name: "Jacko")
      insert(:user, first_name: "Max")

      params = %{"query" => "j"}
      path = conn |> user_path(:index, params)

      conn
      |> get(path)
      |> json_response(200)
      |> assert_ids_from_response([user_1.id, user_2.id, user_3.id])
    end

    test "returns search result on project filter", %{conn: conn} do
      user_1 = insert(:user)
      user_2 = insert(:user)

      project = insert(:project)

      insert(:project_user, user: user_1, project: project)
      insert(:project_user, user: user_2, project: project)
      insert(:project_user)

      params = %{"project_id" => project.id}
      path = conn |> user_path(:index, params)

      conn
      |> get(path)
      |> json_response(200)
      |> assert_ids_from_response([user_1.id, user_2.id])
    end

    test "limit filter limits results on index", %{conn: conn} do
      insert_list(6, :user)

      params = %{"limit" => 5}
      path = conn |> user_path(:index, params)
      json = conn |> get(path) |> json_response(200)

      returned_users_length = json["data"] |> length
      assert returned_users_length == 5
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      user = insert(:user)
      conn
      |> request_show(user)
      |> json_response(200)
      |> assert_id_from_response(user.id)
    end

    @tag :authenticated
    test "renders email when authenticated", %{conn: conn, current_user: current_user} do
      assert conn |> request_show(current_user) |> json_response(200)
    end

    test "renders 404 when id is nonexistent", %{conn: conn} do
      assert conn |> request_show(:not_found) |> json_response(404)
    end
  end

  describe "create" do
    test "creates and renders resource when data is valid", %{conn: conn} do
      attrs = Map.put(@valid_attrs, :password, "password")
      conn = post conn, user_path(conn, :create), %{
        "data" => %{
          "attributes" => attrs
        }
      }

      assert conn |> json_response(201)
    end

    test "calls segment tracking after user is created", %{conn: conn} do
      conn = post conn, user_path(conn, :create), %{
        "meta" => %{},
        "data" => %{
          "type" => "user",
          "attributes" => Map.put(@valid_attrs, :password, "password"),
          "relationships" => @relationships
        }
      }
      id = json_response(conn, 201)["data"]["id"] |> String.to_integer
      assert_received {:track, ^id, "Signed Up", %{}}
    end

    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      attrs = Map.put(@invalid_attrs, :password, "password")
      conn = post conn, user_path(conn, :create), %{
        "data" => %{
          "attributes" => attrs
        }
      }

      assert conn |> json_response(422)
    end
  end

  describe "update" do
    @tag :authenticated
    test "updates and renders chosen resource when data is valid", %{conn: conn} do
      user = insert(:user)
      attrs = Map.put(@valid_attrs, :password, "password")

      params = %{
        "meta" => %{},
        "data" => %{
          "type" => "user",
          "id" => user.id,
          "attributes" => attrs,
          "relationships" => @relationships
        }
      }

      path = user_path(conn, :update, user)

      assert conn |> authenticate(user) |> put(path, params) |> json_response(200)
    end

    test "tracks authentication & update profile events in Segment", %{conn: conn} do
      user = insert(:user, email: "original@mail.com")
      attrs = Map.put(@valid_attrs, :password, "password")

      params = %{
        "meta" => %{},
        "data" => %{
          "type" => "user",
          "id" => user.id,
          "attributes" => attrs,
          "relationships" => @relationships
        }
      }

      path = user_path(conn, :update, user)

      conn =
        conn
        |> authenticate(user)
        |> put(path, params)

      id = json_response(conn, 200)["data"]["id"] |> String.to_integer
      assert_received {:identify, ^id, %{email: "original@mail.com"}}
      assert_received {:track, ^id, "Updated Profile", %{}}
    end

    test "does not update when authorized as different user", %{conn: conn} do
      [user, another_user] = insert_pair(:user)

      attrs = Map.put(@valid_attrs, :password, "password")

      path = user_path(conn, :update, user)

      params = %{
        "meta" => %{},
        "data" => %{
          "type" => "user",
          "id" => user.id,
          "attributes" => attrs,
          "relationships" => @relationships
        }
      }

      conn =
        conn
        |> authenticate(another_user)
        |> put(path, params)

      assert json_response(conn, 403)
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
          "relationships" => @relationships
        }
      }
      conn =
        conn
        |> authenticate(user)
        |> put(path, params)

      json =  json_response(conn, 422)
      assert json["errors"] != %{}
    end

    test "transitions from one state to the next", %{conn: conn} do
      user = insert(:user)
      conn = put authenticate(conn, user), user_path(conn, :update, user), %{
        "data" => %{
          "type" => "user",
          "id" => user.id,
          "attributes" => %{"password" => "password", "state_transition" => "edit_profile"}
        }
      }

      %{"data" => %{"id" => id}} = json_response(conn, 200)
      user = Repo.get(User, id)
      assert user.state == "edited_profile"

      # Transition was successful, so we should unset it
      assert user.state_transition == nil
    end
  end

  describe "github_oauth" do
    @attrs %{"code" => "foo", "state" => "bar"}

    @tag :authenticated
    test "return the user when current user connects successfully", %{conn: conn, current_user: current_user} do
      path = user_path(conn, :github_oauth)

      json = conn |> post(path, @attrs) |> json_response(200)

      assert json["data"]["id"] |> String.to_integer == current_user.id
      assert json["data"]["attributes"]["github-id"]
    end

    @tag :authenticated
    test "tracks event on segment when current user connects successfully", %{conn: conn, current_user: %{id: id}} do
      path = user_path(conn, :github_oauth)

      assert conn |> post(path, @attrs) |> json_response(200)
      expected_data =
        User
        |> Repo.get(id)
        |> CodeCorps.Analytics.SegmentTraitsBuilder.build
      assert_received {:track, ^id, "Connected to GitHub", ^expected_data}
    end

    test "requires authentication", %{conn: conn} do
      path = user_path(conn, :github_oauth)
      assert conn |> post(path, @attrs) |> json_response(401)
    end

    @tag :authenticated
    test "renders 500 if there's a GitHub API error", %{conn: conn} do
      path = user_path(conn, :github_oauth)

      with_mock_api(CodeCorps.GitHub.FailureAPI) do
        assert conn |> post(path, @attrs) |> json_response(500)
      end
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
