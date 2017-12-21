defmodule CodeCorpsWeb.Plug.SetTimberUserContextTest do
  use CodeCorpsWeb.ConnCase

  alias CodeCorpsWeb.Plug.SetTimberUserContext

  @opts SetTimberUserContext.init([])

  describe "init/1" do
    test "returns the given options" do
      assert SetTimberUserContext.init([]) == []
    end
  end

  describe "call/2" do
    test "adds user context when current_user is set" do
      user = insert(:user, first_name: "Josh", last_name: "Smith")
      conn = build_conn() |> assign(:current_user, user)

      result = SetTimberUserContext.call(conn, @opts)

      assert result == conn
      assert Timber.CurrentContext.load() ==
               %{user: %{id: to_string(user.id), name: "Josh Smith", email: user.email}}
    end

    test "adds nothing when current_user is not set" do
      conn = build_conn()

      result = SetTimberUserContext.call(conn, @opts)

      assert result == conn
      assert Timber.CurrentContext.load() == %{}
    end
  end

  describe "add_context/2" do
    test "adds user context correctly when given user is valid" do
      user = insert(:user, first_name: "Josh", last_name: nil)
      conn = build_conn()

      result = SetTimberUserContext.add_context(conn, user)

      assert result == conn
      assert Timber.CurrentContext.load() ==
               %{user: %{id: to_string(user.id), name: "Josh", email: user.email}}
    end

    test "adds nothing when given user is invalid" do
      conn = build_conn()

      result = SetTimberUserContext.add_context(conn, nil)

      assert result == conn
      assert Timber.CurrentContext.load() == %{}
    end
  end
end
