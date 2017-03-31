defmodule CodeCorps.ChangesetViewTest do
  use CodeCorps.Web.ViewCase

  alias CodeCorps.Web.Preview

  test "renders all errors properly" do
    changeset = Preview.create_changeset(%Preview{}, %{})

    rendered_json = render(CodeCorps.ChangesetView, "error.json-api", %{changeset: changeset})

    expected_json = %{
      errors: [
        %{
          id: "VALIDATION_ERROR",
          detail: "can't be blank",
          source: %{
            pointer: "data/attributes/markdown"
          },
          status: 422
        },
        %{
          id: "VALIDATION_ERROR",
          detail: "can't be blank",
          source: %{
            pointer: "data/attributes/user_id"
          },
          status: 422
        }
      ]
    }

    assert rendered_json == expected_json
  end
end
