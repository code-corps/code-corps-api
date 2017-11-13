defmodule CodeCorpsWeb.PasswordResetControllerTest do
  @moduledoc false

  use CodeCorpsWeb.ApiCase, resource_name: :password_reset
  import CodeCorps.TestEnvironmentHelper
  alias CodeCorps.{User, AuthToken}

  test "updates user password when data is valid and deletes auth token model", %{conn: conn} do
    current_user = insert(:user)
    {:ok, auth_token} = AuthToken.changeset(%AuthToken{}, current_user) |> Repo.insert

    assert AuthToken |> Repo.get(auth_token.id) |> Map.get(:id) == auth_token.id

    attrs = %{"token" => auth_token.value, "password" => "123456", "password_confirmation" => "123456"}
    conn = post conn, password_reset_path(conn, :reset_password), attrs
    response = json_response(conn, 201)

    assert response
    encrypted_password = Repo.get(User, current_user.id).encrypted_password

    assert Comeonin.Bcrypt.checkpw("123456", encrypted_password)
    assert AuthToken |> Repo.get(auth_token.id) == nil
  end

  test "does not create resource and renders errors when password does not match", %{conn: conn} do
    current_user = insert(:user)
    {:ok, auth_token} = AuthToken.changeset(%AuthToken{}, current_user) |> Repo.insert
    attrs = %{"token" => auth_token.value, "password" => "123456", "password_confirmation" => "another"}
    conn = post conn, password_reset_path(conn, :reset_password), attrs
    response = json_response(conn, 422)

    assert %{"errors" => [%{"detail" => "Password confirmation passwords do not match"}]} = response
  end

  test "does not create resource and renders errors when token is invalid", %{conn: conn} do
    current_user = insert(:user)
    {:ok, _} = AuthToken.changeset(%AuthToken{}, current_user) |> Repo.insert
    attrs = %{"token" => "random token", "password" => "123456", "password_confirmation" => "123456"}
    conn = post conn, password_reset_path(conn, :reset_password), attrs

    assert json_response(conn, 404)
  end

  test "does not create resource and renders errors when error in token timeout occurs", %{conn: conn} do
    modify_env(:code_corps, password_reset_timeout: 0)

    current_user = insert(:user)
    {:ok, auth_token} = AuthToken.changeset(%AuthToken{}, current_user) |> Repo.insert
    attrs = %{"token" => auth_token.value, "password" => "123456", "password_confirmation" => "123456"}
    conn = post conn, password_reset_path(conn, :reset_password), attrs
    assert json_response(conn, 404)
  end

end
