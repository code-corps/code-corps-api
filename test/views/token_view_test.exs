defmodule CodeCorps.TokenViewTest do
  use CodeCorps.Web.ViewCase

  test "renders show" do
    token = "12345"
    user_id = 1

    rendered_json = render(CodeCorps.TokenView, "show.json", %{token: token, user_id: user_id})

    expected_json = %{
      token: token,
      user_id: user_id
    }

    assert expected_json == rendered_json
  end

  test "renders 401" do
    message = "Silly wabbit, Trix are for kids!"

    rendered_json = render(CodeCorps.TokenView, "401.json", %{message: message})

    expected_json = %{
      errors: [
        %{
          id: "UNAUTHORIZED",
          title: "401 Unauthorized",
          detail: message,
          status: 401
        }
      ]
    }

    assert expected_json == rendered_json
  end

  test "renders 403" do
    message = "Silly wabbit, Trix are for kids!"

    rendered_json = render(CodeCorps.TokenView, "403.json", %{message: message})

    expected_json = %{
      errors: [
        %{
          id: "FORBIDDEN",
          title: "403 Forbidden",
          detail: message,
          status: 403
        }
      ]
    }

    assert expected_json == rendered_json
  end

  test "renders delete" do
    rendered_json = render(CodeCorps.TokenView, "delete.json", %{})

    expected_json = %{
      ok: true
    }

    assert expected_json == rendered_json
  end
end
