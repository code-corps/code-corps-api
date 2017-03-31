defmodule CodeCorps.Web.Helpers.RandomIconColor do
  alias Ecto.Changeset

  @icon_color_generator Application.get_env(:code_corps, :icon_color_generator)

  def generate_icon_color(changeset, icon_color_key) do
    case changeset do
      %Changeset{valid?: true, changes: _changes} ->
        Changeset.put_change(changeset, icon_color_key, @icon_color_generator.generate())
      _ ->
        changeset
    end
  end
end
