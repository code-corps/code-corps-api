defmodule CodeCorpsWeb.OrganizationInviteControllerTest do
  use CodeCorpsWeb.ApiCase, resource_name: :organization_invite
  use Bamboo.Test

  @valid_attrs %{email: "code@corps.com", title: "Code Corps"}
  @invalid_attrs %{email: "code", title: ""}

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      organization_invite = insert(:organization_invite)

      conn
      |> request_show(organization_invite)
      |> json_response(200)
      |> assert_id_from_response(organization_invite.id)
    end

    test "filters resources on index", %{conn: conn} do
      [organization_invite_1, organization_invite_2 | _] = insert_list(3, :organization_invite)

      path = "organization-invites/?filter[id]=#{organization_invite_1.id},#{organization_invite_2.id}"

      conn
      |> get(path)
      |> json_response(200)
      |> assert_ids_from_response([organization_invite_1.id, organization_invite_2.id])
    end

    test "renders 404 when id is nonexistent", %{conn: conn} do
      assert conn |> request_show(:not_found) |> json_response(404)
    end
  end

  describe "create" do
    @tag authenticated: :admin
    test "creates and renders resource when data is valid, sends valid email", %{conn: conn} do
      assert conn |> request_create(@valid_attrs) |> json_response(201)

      organization_invite_email = 
        CodeCorps.OrganizationInvite
        |> first()
        |> Repo.one()
        |> CodeCorps.Emails.OrganizationInviteEmail.create()

      assert_delivered_email organization_invite_email  
    end

    @tag authenticated: :admin
    test "renders 422 error when data is invalid", %{conn: conn} do
      assert conn |> request_create(@invalid_attrs) |> json_response(422)
    end

    test "renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_create |> json_response(401)
    end
  end

  describe "update" do
    @tag authenticated: :admin
    test "updates chosen resource", %{conn: conn} do
      assert conn |> request_update(@valid_attrs) |> json_response(200)
    end

    test "renders 401 when not authenticated", %{conn: conn} do
      assert conn |> request_update |> json_response(401)
    end

    @tag authenticated: :admin
    test "renders 404 when id is nonexistent", %{conn: conn} do
      assert conn |> request_update(:not_found) |> json_response(404)
    end
  end
end