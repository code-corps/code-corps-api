defmodule CodeCorps.ProjectViewTest do
  use CodeCorps.ConnCase, async: true

  alias CodeCorps.Repo

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders all attributes and relationships properly" do
    organization = insert(:organization)
    project = insert(:project, organization: organization)
    post = insert(:post, project: project)
    project_category = insert(:project_category, project: project)
    project_skill = insert(:project_skill, project: project)

    project =
      CodeCorps.Project
      |> Repo.get(project.id)
      |> CodeCorps.Repo.preload([:categories, :organization, :posts, :skills])

    rendered_json =  render(CodeCorps.ProjectView, "show.json-api", data: project)

    expected_json = %{
      data: %{
        attributes: %{
          "description" => project.description,
          "icon-large-url" => CodeCorps.ProjectIcon.url({project.icon, project}, :large),
          "icon-thumb-url" => CodeCorps.ProjectIcon.url({project.icon, project}, :thumb),
          "inserted-at" => project.inserted_at,
          "long-description-body" => project.long_description_body,
          "long-description-markdown" => project.long_description_markdown,
          "slug" => project.slug,
          "title" => project.title,
          "updated-at" => project.updated_at,
        },
        id: project.id |> Integer.to_string,
        relationships: %{
          "categories" => %{
            data: [
              %{
                id: project_category.category_id |> Integer.to_string,
                type: "category"
              }
            ]
          },
          "organization" => %{
            data: %{
              id: organization.id |> Integer.to_string,
              type: "organization"
            }
          },
          "posts" => %{
            data: [
              %{
                id: post.id |> Integer.to_string,
                type: "post"
              }
            ]
          },
          "project-categories" => %{
            data: [
              %{
                id: project_category.id |> Integer.to_string,
                type: "project-category"
              }
            ]
          },
          "project-skills" => %{
            data: [
              %{
                id: project_skill.id |> Integer.to_string,
                type: "project-skill"
              }
            ]
          },
          "skills" => %{
            data: [
              %{
                id: project_skill.skill_id |> Integer.to_string,
                type: "skill"
              }
            ]
          },
        },
        type: "project",
      },
      jsonapi: %{
        version: "1.0"
      }
    }

    assert rendered_json == expected_json
  end
end
