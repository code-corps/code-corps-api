defmodule CodeCorps.TokenView do
  use CodeCorps.Web, :view

  def render("show.json", %{token: token, user_id: user_id}) do
    %{
      token: token,
      user_id: user_id,
    }
  end

  def render("error.json", %{message: message}) do
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

  def render("delete.json", _) do
    %{ok: true}
  end
end
