defmodule CodeCorps.PasswordResetViewTest do
  use CodeCorps.ViewCase

  test "renders show" do
    args = %{
      email: "test@test.com",
      token: "abc123",
      user_id: 123
    }

    rendered_json = render(CodeCorps.PasswordResetView, "show.json", args)

    expected_json = %{
      email: "test@test.com",
      token: "abc123",
      user_id: 123
    }

    assert expected_json == rendered_json
  end

end
