defmodule CodeCorpsWeb.PasswordView do
  use CodeCorpsWeb, :view

  def render("show.json", %{email: email}) do
    %{
      email: email
    }
  end

end
