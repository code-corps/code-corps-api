defmodule CodeCorpsWeb.TokenView do
  @moduledoc false
  use CodeCorpsWeb, :view

  def render("show.json", %{token: token, user_id: user_id}) do
    %{
      token: token,
      user_id: user_id,
    }
  end

  def render("401.json", %{message: message}) do
    %{
      errors: [
        %{
          id: "UNAUTHORIZED",
          title: "401 Unauthorized",
          detail: message,
          status: 401,
        }
      ]
    }
  end

  def render("403.json", %{message: message}) do
    %{
      errors: [
        %{
          id: "FORBIDDEN",
          title: "403 Forbidden",
          detail: message,
          status: 403,
        }
      ]
    }
  end

  def render("delete.json", _) do
    %{ok: true}
  end
end
