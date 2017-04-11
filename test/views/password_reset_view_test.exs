defmodule CodeCorps.Web.PasswordResetViewTest do
  use CodeCorps.Web.ViewCase

  test "renders show" do
    email = "wat@codecorps.org"

    rendered_json = render(CodeCorps.Web.PasswordResetView, "show.json", %{email: email})

    expected_json = %{
      email: email
    }

    assert expected_json == rendered_json
  end

end
