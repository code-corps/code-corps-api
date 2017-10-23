defmodule CodeCorps.Emails.ForgotPasswordEmailTest do
  use CodeCorps.ModelCase
  use Bamboo.Test

  alias CodeCorps.{AuthToken, Emails.ForgotPasswordEmail, WebClient}

  test "forgot password email works" do
    user = insert(:user)
    { :ok, %AuthToken{ value: token } } = AuthToken.changeset(%AuthToken{}, user) |> Repo.insert

    email = ForgotPasswordEmail.create(user, token)
    assert email.from == "Code Corps<team@codecorps.org>"
    assert email.to == user.email
    { :link, encoded_link } = email.private.template_model |> Enum.at(0)
    assert "#{WebClient.url()}/password/reset?token=#{token}" == encoded_link
  end
end
