defmodule CodeCorpsWeb.ChangesetViewTest do
  use CodeCorpsWeb.ViewCase

  alias CodeCorps.Preview

  test "renders all errors properly" do
    changeset = Preview.create_changeset(%Preview{}, %{})

    rendered_json = render(CodeCorpsWeb.ChangesetView, "422.json", %{changeset: changeset})

    expected_json = %{
      errors: [
        %{
          detail: "Markdown can't be blank",
          source: %{
            pointer: "data/attributes/markdown"
          },
          status: "422",
          title: "can't be blank"
        },
        %{
          detail: "User can't be blank",
          source: %{
            pointer: "data/attributes/user_id"
          },
          status: "422",
          title: "can't be blank"
        }
      ],
      jsonapi: %{
        version: "1.0"
      }
    }

    assert rendered_json == expected_json
  end
end
