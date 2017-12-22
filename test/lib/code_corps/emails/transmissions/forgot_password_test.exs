defmodule CodeCorps.Emails.Transmissions.ForgotPasswordTest do
  use CodeCorps.DbAccessCase

  alias CodeCorps.{Emails.Transmissions.ForgotPassword, WebClient}

  test "has a template_id assigned" do
    assert ForgotPassword.template_id
  end

  describe "build/2" do
    test "provides substitution data for all keys used by template" do
      user = insert(:user)
      token = "foo"
      %{substitution_data: data} = ForgotPassword.build(user, token)

      expected_keys =
        ForgotPassword.template_id
        |> CodeCorps.SparkPostHelpers.get_keys_used_by_template
      assert data |> Map.keys == expected_keys
    end

    test "builds correct transmission model" do
      user = insert(:user)
      token = "foo"

      %{substitution_data: data, recipients: [recipient]} =
        ForgotPassword.build(user, token)

      assert data.from_name == "Code Corps"
      assert data.from_email == "team@codecorps.org"
      assert data.link == "#{WebClient.url()}/password/reset?token=#{token}"

      assert recipient.address.email == user.email
      assert recipient.address.name == user.first_name
    end
  end
end
