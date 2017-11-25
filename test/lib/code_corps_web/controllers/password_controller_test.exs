defmodule CodeCorpsWeb.PasswordControllerTest do
  @moduledoc false

  use CodeCorpsWeb.ApiCase, resource_name: :password
  use Bamboo.Test

  alias CodeCorps.AuthToken

  test "Unauthenticated - creates and renders resource when email is valid", %{conn: conn} do
    user = insert(:user)
    attrs = %{"email" => user.email}
    conn = post conn, password_path(conn, :forgot_password), attrs
    response = json_response(conn, 200)

    assert response == %{ "email" => user.email }

    %AuthToken{value: token} = Repo.get_by(AuthToken, user_id: user.id)
    assert_delivered_email CodeCorps.Emails.ForgotPasswordEmail.create(user, token)
  end

  @tag :authenticated
  test "Authenticated - creates and renders resource when email is valid and removes session", %{conn: conn} do
    user = insert(:user)
    attrs = %{"email" => user.email}
    conn = post conn, password_path(conn, :forgot_password), attrs
    response = json_response(conn, 200)

    assert response == %{ "email" => user.email }

    %AuthToken{value: token} = Repo.get_by(AuthToken, user_id: user.id)
    assert_delivered_email CodeCorps.Emails.ForgotPasswordEmail.create(user, token)

    refute CodeCorps.Guardian.Plug.authenticated?(conn)
  end

  test "does not create resource and renders 200 when email is invalid", %{conn: conn} do
    user = insert(:user)
    attrs = %{"email" => "random_email@gmail.com"}
    conn = post conn, password_path(conn, :forgot_password), attrs
    response = json_response(conn, 200)

    assert response == %{ "email" => "random_email@gmail.com" }

    refute_delivered_email CodeCorps.Emails.ForgotPasswordEmail.create(user, nil)
  end

end
