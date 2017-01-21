defmodule CodeCorps.SluggedRouteViewTest do
  use CodeCorps.ConnCase, async: true

  import Phoenix.View, only: [render: 3]

  test "renders all attributes and relationships properly for organization" do
    organization = insert(:organization)
    slugged_route = insert(:slugged_route, organization: organization)

    rendered_json = render(CodeCorps.SluggedRouteView, "show.json-api", data: slugged_route)

    expected_json = %{
      "data" => %{
        "id" => slugged_route.id |> Integer.to_string,
        "type" => "slugged-route",
        "attributes" => %{
          "inserted-at" => slugged_route.inserted_at,
          "slug" => slugged_route.slug,
          "updated-at" => slugged_route.updated_at,
        },
        "relationships" => %{
          "organization" => %{
            "data" => %{"id" => slugged_route.organization_id |> Integer.to_string, "type" => "organization"}
          },
          "user" => %{
            "data" => nil
          }
        }
      },
      "jsonapi" => %{
        "version" => "1.0"
      }
    }

    assert rendered_json == expected_json
  end

  test "renders all attributes and relationships properly for user" do
    user = insert(:user)
    slugged_route = insert(:slugged_route, user: user)

    rendered_json = render(CodeCorps.SluggedRouteView, "show.json-api", data: slugged_route)

    expected_json = %{
      "data" => %{
        "id" => slugged_route.id |> Integer.to_string,
        "type" => "slugged-route",
        "attributes" => %{
          "inserted-at" => slugged_route.inserted_at,
          "slug" => slugged_route.slug,
          "updated-at" => slugged_route.updated_at,
        },
        "relationships" => %{
          "organization" => %{
            "data" => nil
          },
          "user" => %{
            "data" => %{"id" => slugged_route.user_id |> Integer.to_string, "type" => "user"}
          }
        }
      },
      "jsonapi" => %{
        "version" => "1.0"
      }
    }

    assert rendered_json == expected_json
  end
end
