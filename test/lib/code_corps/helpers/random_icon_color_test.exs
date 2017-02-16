defmodule CodeCorps.RandomIconColor.RandomIconColorTest do
  use ExUnit.Case, async: true
  import CodeCorps.Helpers.RandomIconColor
  import Ecto.Changeset

  test "inserts color into changeset" do
    changeset = generate_icon_color(cast({%{}, %{}}, %{}, []), :color_key)
    assert get_field(changeset, :color_key) == "blue"
  end

  test "ignores invalid changeset" do
    changeset = {%{}, %{color_key: :required}}
      |> cast(%{}, [])
      |> validate_required(:color_key)
    assert generate_icon_color(changeset, :color_key) == changeset
  end
end
