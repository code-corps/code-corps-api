defmodule CodeCorpsWeb.ProjectControllerTest do
  @moduledoc false

  use CodeCorpsWeb.ApiCase, resource_name: :project
  use Bamboo.Test

  alias CodeCorps.{Analytics.SegmentTraitsBuilder, Emails, Project, Repo}

  @valid_attrs %{
    cloudinary_public_id: "foo123",
    description: "Valid description",
    title: "Valid project"
  }
  @invalid_attrs %{title: ""}

  describe "index" do
    test "filters on index", %{conn: conn} do
      [project_1, project_2] = insert_pair(:project, approved: true)
      project_3 = insert(:project, approved: false)

      path = "/projects?approved=true"

      returned_ids =
        conn
        |> get(path)
        |> json_response(200)
        |> ids_from_response

      assert project_1.id in returned_ids
      assert project_2.id in returned_ids
      refute project_3.id in returned_ids
    end

    test "lists all entries for organization specified by slug", %{conn: conn} do
      organization_slug = "test-organization"
      organization = insert(:organization, name: "Test Organization", slug: organization_slug)
      insert(:slugged_route, organization: organization, slug: organization_slug)
      [project_1, project_2] = insert_pair(:project, organization: organization)
      project_3 = insert(:project)

      path = ("/#{organization_slug}/projects")

      returned_ids =
        conn
        |> get(path)
        |> json_response(200)
        |> ids_from_response

      assert project_1.id in returned_ids
      assert project_2.id in returned_ids
      refute project_3.id in returned_ids
    end

    test "listing by organization slug is case insensitive", %{conn: conn} do
      organization = insert(:organization)
      insert(:slugged_route, slug: "codecorps", organization: organization)

      assert conn |> get("/codeCorps/projects") |> json_response(200)
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      project = insert(:project)

      conn
      |> request_show(project)
      |> json_response(200)
      |> assert_id_from_response(project.id)
    end

    test "shows chosen resource retrieved by slug", %{conn: conn} do
      organization = insert(:organization)
      project = insert(:project, organization: organization)

      path = "#{organization.slug}/#{project.slug}"

      conn
      |> get(path)
      |> json_response(200)
      |> assert_id_from_response(project.id)
    end

    test "retrieval by slug is case insensitive", %{conn: conn} do
      organization = insert(:organization, slug: "codecorps")
      insert(:project, slug: "codecorpsproject", organization: organization)

      assert conn |> get("codeCorps/codeCorpsProject") |> json_response(200)
    end
  end

  describe "create" do
    @tag :authenticated
    test "creates and renders resource when attributes are valid", %{conn: conn, current_user: current_user} do
      category = insert(:category)
      organization = insert(:organization, owner: current_user)
      skill = insert(:skill)

      params = %{
        categories: [category],
        organization: organization,
        skills: [skill]
      }

      attrs = @valid_attrs |> Map.merge(params)
      response = conn |> request_create(attrs)
      assert %{assigns: %{data: %{task_lists: [_inbox, _backlog, _in_progress, _done]}}} = response
      assert response |> json_response(201)

      user_id = current_user.id
      traits = Project |> Repo.one() |> SegmentTraitsBuilder.build
      assert_received {:track, ^user_id, "Created Project", ^traits}
    end

    @tag :authenticated
    test "renders 422 when attributes are invalid", %{conn: conn, current_user: current_user} do
      organization = insert(:organization, owner: current_user)
      attrs = @invalid_attrs |> Map.merge(%{organization: organization})
      assert conn |> request_create(attrs) |> json_response(422)
    end

    test "renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_create |> json_response(401)
    end

    @tag :authenticated
    test "renders 403 when not authorized", %{conn: conn} do
      # Need the organization in order to access membership in the project policy
      attrs = %{organization: insert(:organization)}
      assert conn |> request_create(attrs) |> json_response(403)
    end
  end

  describe "update" do
    @tag :authenticated
    test "updates and renders resource when attributes are valid", %{conn: conn, current_user: current_user} do
      project = insert(:project, approval_requested: false)
      insert(:project_user, project: project, user: current_user, role: "owner")
      insert(:user, admin: true)
      attrs = @valid_attrs |> Map.merge(%{approval_requested: true})

      assert conn |> request_update(project, attrs) |> json_response(200)

      project =
        Project
        |> Repo.get_by(approved: true)
        |> Repo.preload([:organization])

      email =
        project
        |> CodeCorps.SparkPost.Emails.ProjectApprovalRequest.build()

      assert_received ^email

      user_id = current_user.id
      traits = project |> SegmentTraitsBuilder.build
      assert_received {:track, ^user_id, "Requested Project Approval", ^traits}
    end

    @tag authenticated: :admin
    test "sends the approved email when approved", %{conn: conn, current_user: current_user} do
      project = insert(:project, approved: false)
      insert(:project_user, project: project, role: "owner")
      attrs = @valid_attrs |> Map.merge(%{approved: true})

      assert conn |> request_update(project, attrs) |> json_response(200)

      project =
        Project
        |> Repo.get_by(approved: true)
        |> Repo.preload([:organization])

      email =
        project
        |> Emails.ProjectApprovedEmail.create()

      assert_delivered_email(email)

      user_id = current_user.id
      traits = project |> SegmentTraitsBuilder.build
      assert_received {:track, ^user_id, "Approved Project", ^traits}
    end

    @tag :authenticated
    test "renders errors when attributes are invalid", %{conn: conn, current_user: current_user} do
      project = insert(:project)
      insert(:project_user, project: project, user: current_user, role: "owner")
      assert conn |> request_update(project, @invalid_attrs) |> json_response(422)
    end

    test "renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_update |> json_response(401)
    end

    @tag :authenticated
    test "renders 403 when not authorized", %{conn: conn} do
      # Need the organization in order to access membership in the project policy
      attrs = %{organization: insert(:organization)}
      assert conn |> request_update(attrs) |> json_response(403)
    end

    @tag authenticated: :admin
    test "renders 404 when not found", %{conn: conn} do
      assert conn |> request_update(:not_found) |> json_response(404)
    end
  end
end
