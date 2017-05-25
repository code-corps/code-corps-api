defmodule CodeCorps.PasswordViewTest do
  use CodeCorps.ViewCase

  test "renders show" do
    email = "wat@codecorps.org"

    rendered_json = render(CodeCorps.PasswordView, "show.json", %{email: email})

    expected_json = %{
      email: email
    }

    assert expected_json == rendered_json
    refute Map.has_key?(expected_json, :token)
  end

end
