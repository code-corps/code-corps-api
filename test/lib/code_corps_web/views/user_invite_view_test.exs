defmodule CodeCorpsWeb.UserInviteViewTest do
  @moduledoc false

  use CodeCorpsWeb.ViewCase

  test "renders all attributes and relationships properly for unclaimed plain user invite" do
    user_invite = insert(:user_invite)

    rendered_json = render(CodeCorpsWeb.UserInviteView, "show.json-api", data: user_invite)

    expected_json = %{
      "data" => %{
        "id" => "#{user_invite.id}",
        "type" => "user-invite",
        "attributes" => %{
          "email" => user_invite.email,
          "name" => user_invite.name,
          "role" => nil
        },
        "relationships" => %{
          "invitee" => %{"data" => nil},
          "inviter" => %{
            "data" => %{"id" => "#{user_invite.inviter_id}", "type" => "user"}
          },
          "project" => %{"data" => nil}
        }
      },
      "jsonapi" => %{
        "version" => "1.0"
      }
    }

    assert rendered_json == expected_json
  end

  test "renders all attributes and relationships properly for claimed plain user invite" do
    user_invite = insert(:user_invite, invitee: :user |> build())

    rendered_json = render(CodeCorpsWeb.UserInviteView, "show.json-api", data: user_invite)

    expected_json = %{
      "data" => %{
        "id" => "#{user_invite.id}",
        "type" => "user-invite",
        "attributes" => %{
          "email" => user_invite.email,
          "name" => user_invite.name,
          "role" => nil
        },
        "relationships" => %{
          "invitee" => %{
            "data" => %{"id" => "#{user_invite.invitee_id}", "type" => "user"}
          },
          "inviter" => %{
            "data" => %{"id" => "#{user_invite.inviter_id}", "type" => "user"}
          },
          "project" => %{"data" => nil}
        }
      },
      "jsonapi" => %{
        "version" => "1.0"
      }
    }

    assert rendered_json == expected_json
  end

  test "renders all attributes and relationships properly for unclaimed project user invite" do
    user_invite = insert(:user_invite, project: :project |> build(), role: "contributor")

    rendered_json = render(CodeCorpsWeb.UserInviteView, "show.json-api", data: user_invite)

    expected_json = %{
      "data" => %{
        "id" => "#{user_invite.id}",
        "type" => "user-invite",
        "attributes" => %{
          "email" => user_invite.email,
          "name" => user_invite.name,
          "role" => user_invite.role
        },
        "relationships" => %{
          "invitee" => %{"data" => nil},
          "inviter" => %{
            "data" => %{"id" => "#{user_invite.inviter_id}", "type" => "user"}
          },
          "project" => %{
            "data" => %{"id" => "#{user_invite.project_id}", "type" => "project"}
          }
        }
      },
      "jsonapi" => %{
        "version" => "1.0"
      }
    }

    assert rendered_json == expected_json
  end

  test "renders all attributes and relationships properly for claimed project user invite" do
    user_invite =
      insert(
        :user_invite,
        invitee: :user |> build(),
        project: :project |> build(),
        role: "contributor"
      )

    rendered_json = render(CodeCorpsWeb.UserInviteView, "show.json-api", data: user_invite)

    expected_json = %{
      "data" => %{
        "id" => "#{user_invite.id}",
        "type" => "user-invite",
        "attributes" => %{
          "email" => user_invite.email,
          "name" => user_invite.name,
          "role" => user_invite.role
        },
        "relationships" => %{
          "invitee" => %{
            "data" => %{"id" => "#{user_invite.invitee_id}", "type" => "user"}
          },
          "inviter" => %{
            "data" => %{"id" => "#{user_invite.inviter_id}", "type" => "user"}
          },
          "project" => %{
            "data" => %{"id" => "#{user_invite.project_id}", "type" => "project"}
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
