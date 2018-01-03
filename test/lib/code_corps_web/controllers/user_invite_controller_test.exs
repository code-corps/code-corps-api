defmodule CodeCorpsWeb.UserInviteControllerTest do
  @moduledoc false

  use CodeCorpsWeb.ApiCase

  alias CodeCorps.{Repo, UserInvite}

  describe "create" do
    @tag :authenticated
    test "creates an invite, renders 201", %{conn: conn, current_user: current_user} do
      attrs = %{
        "email" => "foo@mail.com",
        "inviter_id" => "#{current_user.id}",
        "name" => "Foo"
      }

      path = conn |> user_invite_path(:create)
      json = conn |> post(path, attrs) |> json_response(201)

      created_invite =
        Repo.get_by(UserInvite, email: "foo@mail.com", inviter_id: current_user.id, name: "Foo")

      assert created_invite

      json |> assert_id_from_response(created_invite.id)
    end

    @tag :authenticated
    test "creates an invite for a project, renders 201", %{conn: conn, current_user: current_user} do
      project = insert(:project)
      insert(:project_user, role: "admin", project: project, user: current_user)

      attrs = %{
        "email" => "foo@mail.com",
        "inviter_id" => "#{current_user.id}",
        "name" => "Foo",
        "project_id" => "#{project.id}",
        "role" => "contributor"
      }

      path = conn |> user_invite_path(:create)
      json = conn |> post(path, attrs) |> json_response(201)

      created_invite =
        Repo.get_by(
          UserInvite,
          email: "foo@mail.com",
          inviter_id: current_user.id,
          name: "Foo",
          project_id: project.id,
          role: "contributor"
        )

      assert created_invite

      json |> assert_id_from_response(created_invite.id)
    end

    @tag :authenticated
    test "tracks creation of invite", %{conn: conn, current_user: %{id: user_id}} do
      attrs = %{
        "email" => "foo@mail.com",
        "inviter_id" => "#{user_id}",
        "name" => "Foo"
      }

      path = conn |> user_invite_path(:create)
      conn |> post(path, attrs)

      created_invite = Repo.one(UserInvite)
      traits = created_invite |> CodeCorps.Analytics.SegmentTraitsBuilder.build()

      assert_received({:track, ^user_id, "Created User Invite", ^traits})
    end

    test "renders 401 when unauthenticated", %{conn: conn} do
      attrs = %{
        "email" => "foo@mail.com",
        "name" => "Foo"
      }

      path = conn |> user_invite_path(:create)
      assert conn |> post(path, attrs) |> json_response(401)
      refute Repo.one(UserInvite)
    end

    @tag :authenticated
    test "renders 403 on authorization error", %{conn: conn, current_user: current_user} do
      project = insert(:project)

      attrs = %{
        "email" => "foo@mail.com",
        "inviter_id" => "#{current_user.id}",
        "name" => "Foo",
        "project_id" => "#{project.id}",
        "role" => "contributor"
      }

      path = conn |> user_invite_path(:create)
      assert conn |> post(path, attrs) |> json_response(403)
      refute Repo.one(UserInvite)
    end

    @tag :authenticated
    test "renders 422 on validation error", %{conn: conn, current_user: current_user} do
      attrs = %{"inviter_id" => "#{current_user.id}"}

      path = conn |> user_invite_path(:create)
      assert conn |> post(path, attrs) |> json_response(422)

      refute Repo.one(UserInvite)
    end
  end
end
