defmodule CodeCorps.PasswordResetView do
  use CodeCorps.Web, :view

  def render("show.json", %{token: token}) do
    %{
      token: token
    }
  end

end
