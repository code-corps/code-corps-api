defmodule CodeCorpsWeb.PasswordView do
  @moduledoc false
  use CodeCorpsWeb, :view

  def render("show.json", %{email: email}) do
    %{
      email: email
    }
  end

end
