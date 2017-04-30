defmodule CodeCorps.PasswordResetViewTest do
  use CodeCorps.ViewCase

  test "renders show" do
    token = "zzz123"

    rendered_json = render(CodeCorps.PasswordResetView, "show.json", %{token: token})

    expected_json = %{
      token: token
    }

    assert expected_json == rendered_json
  end

end
