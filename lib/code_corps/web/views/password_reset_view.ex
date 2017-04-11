defmodule CodeCorps.Web.PasswordResetView do
  use CodeCorps.Web, :view

  def render("show.json", %{email: email}) do
    %{
      email: email
    }
  end

end
