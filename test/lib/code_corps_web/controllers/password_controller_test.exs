defmodule CodeCorpsWeb.PasswordControllerTest do
  @moduledoc false

  use CodeCorpsWeb.ApiCase, resource_name: :password

  alias CodeCorps.AuthToken

  test "Unauthenticated - creates and renders resource when email is valid", %{conn: conn} do
    user = insert(:user)
    attrs = %{"email" => user.email}
    conn = post conn, password_path(conn, :forgot_password), attrs
    response = json_response(conn, 200)

    assert response == %{ "email" => user.email }

    %AuthToken{value: token} = Repo.get_by(AuthToken, user_id: user.id)
    expected_email = CodeCorps.Emails.Transmissions.ForgotPassword.build(user, token)
    assert_received ^expected_email
  end

  @tag :authenticated
  test "Authenticated - creates and renders resource when email is valid and removes session", %{conn: conn} do
    user = insert(:user)
    attrs = %{"email" => user.email}
    conn = post conn, password_path(conn, :forgot_password), attrs
    response = json_response(conn, 200)

    assert response == %{ "email" => user.email }

    %AuthToken{value: token} = Repo.get_by(AuthToken, user_id: user.id)
    expected_email = CodeCorps.Emails.Transmissions.ForgotPassword.build(user, token)
    assert_received ^expected_email

    refute CodeCorps.Guardian.Plug.authenticated?(conn)
  end

  test "does not create resource and renders 200 when email is invalid", %{conn: conn} do
    insert(:user)
    attrs = %{"email" => "random_email@gmail.com"}
    conn = post conn, password_path(conn, :forgot_password), attrs
    response = json_response(conn, 200)

    assert response == %{ "email" => "random_email@gmail.com" }

    refute_received %SparkPost.Transmission{}
  end
end
