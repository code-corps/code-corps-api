defmodule CodeCorps.ProjectControllerTest do
  use CodeCorps.ConnCase

  alias CodeCorps.Project

  @valid_attrs %{
    title: "Valid project",
    description: "Valid project description",
    long_description_markdown: "Valid **markdown**"
  }

  @invalid_attrs %{
    title: ""
  }

  setup do
    conn =
      %{build_conn | host: "api."}
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  describe "#index" do
    test "lists all entries on index", %{conn: conn} do
      conn = get conn, project_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end

    test "lists all entries for organization specified by slug", %{conn: conn} do
      organization = insert_organization(%{name: "Test Organization"})
      project_1 = insert_project(%{title: "Test Project 1", organization_id: organization.id})
      project_2 = insert_project(%{title: "Test Project 2", organization_id: organization.id})

      conn = get conn, "/test-organization/projects"

      data =
        conn
        |> json_response(200)
        |> Map.get("data")

      assert Enum.count(data) == 2

      actual_ids =
        data
        |> Enum.map(& &1["id"])
        |> Enum.map(&Integer.parse(&1) |> elem(0))
        |> Enum.sort

      expected_ids =
        [project_1, project_2]
        |> Enum.map(& &1.id)
        |> Enum.sort

      assert expected_ids == actual_ids
    end
  end

  describe "#show" do
    test "shows chosen resource", %{conn: conn} do
      organization = insert_organization()
      project = insert_project(%{
        title: "Test project",
        description: "Test project description",
        long_description_markdown: "A markdown **description**",
        organization_id: organization.id})

      conn = get conn, project_path(conn, :show, project)
      data = json_response(conn, 200)["data"]
      assert data["id"] == "#{project.id}"
      assert data["type"] == "project"
      assert data["attributes"]["title"] == "Test project"
      assert data["attributes"]["description"] == "Test project description"
      assert data["attributes"]["long-description-markdown"] == "A markdown **description**"
      assert data["relationships"]["organization"]["data"]["id"] == Integer.to_string(organization.id)
    end

    test "shows chosen resource retrieved by slug", %{conn: conn} do
      organization = insert_organization(%{name: "Test Organization"})
      project = insert_project(%{
        title: "Test project",
        description: "Test project description",
        long_description_markdown: "A markdown **description**",
        organization_id: organization.id})

      conn = get conn, "/test-organization/test-project"

      data =
        conn
        |> json_response(200)
        |> Map.get("data")

      assert data["id"] == "#{project.id}"
      assert data["type"] == "project"
      assert data["attributes"]["title"] == "Test project"
      assert data["attributes"]["description"] == "Test project description"
      assert data["attributes"]["long-description-markdown"] == "A markdown **description**"
      assert data["relationships"]["organization"]["data"]["id"] == Integer.to_string(organization.id)
    end
  end

  describe "create" do
    test "creates and renders resource when attributes are valid", %{conn: conn} do
      organization = insert_organization

      payload = %{
        data: %{
          type: "project",
          attributes: @valid_attrs,
          relationships: %{
            organization: %{
              data: %{ id: organization.id, type: "organization" }
            }
          }
        }
      }

      conn = post conn, project_path(conn, :create), payload

      id = json_response(conn, 201)["data"]["id"]
      assert id
      project =
        Project
        |> preload([:organization])
        |> Repo.get(id)

      assert project
      assert project.title == "Valid project"
      assert project.description == "Valid project description"
      assert project.long_description_markdown == "Valid **markdown**"
      assert project.long_description_body == "<p>Valid <strong>markdown</strong></p>\n"
      assert project.organization_id == organization.id
    end

    @tag :requires_env
    test "uploads a icon to S3", %{conn: conn} do
      project = insert_project()
      icon_data = "data:image/gif;base64,R0lGODlhAQABAIAAAAUEBAAAACwAAAAAAQABAAACAkQBADs="
      attrs = Map.put(@valid_attrs, :base64_icon_data, icon_data)
      conn = put conn, project_path(conn, :update, project), %{
        "meta" => %{},
        "data" => %{
          "type" => "project",
          "id" => project.id,
          "attributes" => attrs
        }
      }

      data = json_response(conn, 201)["data"]
      large_url = data["attributes"]["icon-large-url"]
      assert large_url
      assert String.contains? large_url, "/projects/#{project.id}/large"
      thumb_url = data["attributes"]["icon-thumb-url"]
      assert thumb_url
      assert String.contains? thumb_url, "/projects/#{project.id}/thumb"
    end

    test "renders errors when attributes are invalid", %{conn: conn} do
      payload = %{
        "meta" => %{},
        "data" => %{
          "type" => "project",
          "attributes" => @invalid_attrs
        }
      }

      conn = post(conn, project_path(conn, :create), payload)
      errors =
        conn
        |> json_response(422)
        |> Map.get("errors")

      assert errors != %{}
      assert errors["title"] == ["can't be blank"]

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update" do
    test "updates and renders resource when attributes are valid", %{conn: conn} do
      organization = insert_organization
      project = insert_project(%{
        organization_id: organization.id,
        title: "Initial title",
        description: "Initial description",
        long_description_markdown: "Initial long description"
      })

      payload = %{
        data: %{
          id: project.id,
          type: "project",
          attributes: @valid_attrs
        }
      }

      conn = patch conn, project_path(conn, :update, project), payload

      id = json_response(conn, 201)["data"]["id"]
      assert id
      project =
        Project
        |> preload([:organization])
        |> Repo.get(id)

      assert project
      assert project.title == "Valid project"
      assert project.description == "Valid project description"
      assert project.long_description_markdown == "Valid **markdown**"
      assert project.long_description_body == "<p>Valid <strong>markdown</strong></p>\n"
      assert project.organization_id == organization.id
    end

    test "renders errors when attributes are invalid", %{conn: conn} do
      organization = insert_organization
      project = insert_project(%{
        organization_id: organization.id,
        title: "Initial title",
        description: "Initial description",
        long_description_markdown: "Initial long description"
      })

      payload = %{
        data: %{
          id: project.id,
          type: "project",
          attributes: @invalid_attrs
        }
      }

      conn = patch(conn, project_path(conn, :update, project), payload)

      errors =
        conn
        |> json_response(422)
        |> Map.get("errors")

      assert errors != %{}
      assert errors["title"] == ["can't be blank"]

      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
