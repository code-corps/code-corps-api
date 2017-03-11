defmodule CodeCorps.PasswordResetControllerTest do
  @moduledoc false

  use CodeCorps.ApiCase, resource_name: :password_reset
  alias CodeCorps.AuthToken

  @tag :authenticated
  test "creates and renders resource when data is valid", %{conn: conn, current_user: current_user} do
    {:ok, auth_token} = AuthToken.changeset(%AuthToken{}, current_user) |> Repo.insert
    attrs = %{"value" => auth_token.value, "password" => "123456", "password_confirmation" => "123456"}
    conn = post conn, password_reset_path(conn, :reset_password), attrs
    response = json_response(conn, 201)
    assert response
  end

  # test "does not create resource and renders errors when data is invalid", %{conn: conn} do
  #   conn = post conn, password_reset_path(conn, :create), password_reset: @invalid_attrs
  #   assert json_response(conn, 422)["errors"] != %{}
  # end

end
