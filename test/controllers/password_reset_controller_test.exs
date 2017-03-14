defmodule CodeCorps.PasswordResetControllerTest do
  @moduledoc false

  use CodeCorps.ApiCase, resource_name: :password_reset
  alias CodeCorps.AuthToken

  @tag :authenticated
  test "creates and renders resource when data is valid", %{conn: conn, current_user: current_user} do
    {:ok, auth_token} = AuthToken.changeset(%AuthToken{}, current_user) |> Repo.insert
    attrs = %{"token" => auth_token.value, "password" => "123456", "password_confirmation" => "123456"}
    conn = post conn, password_reset_path(conn, :reset_password), attrs
    response = json_response(conn, 201)
    assert response
  end

  @tag :authenticated
  test "does not create resource and renders errors when password does not match", %{conn: conn, current_user: current_user} do
    {:ok, auth_token} = AuthToken.changeset(%AuthToken{}, current_user) |> Repo.insert
    attrs = %{"token" => auth_token.value, "password" => "123456", "password_confirmation" => "another"}
    conn = post conn, password_reset_path(conn, :reset_password), attrs
    assert json_response(conn, 422)
  end

  @tag :authenticated
  test "does not create resource and renders errors when token is invalid", %{conn: conn, current_user: current_user} do
    {:ok, _} = AuthToken.changeset(%AuthToken{}, current_user) |> Repo.insert
    attrs = %{"token" => "random token", "password" => "123456", "password_confirmation" => "123456"}
    conn = post conn, password_reset_path(conn, :reset_password), attrs
    assert json_response(conn, 422)
  end

end
