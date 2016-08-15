defmodule CodeCorps.PreviewTest do
  use CodeCorps.ModelCase

  alias CodeCorps.Preview

  test "changeset renders body html from markdown" do
    changeset = Preview.changeset(%Preview{}, %{markdown: "A **strong** element"}, nil)
    assert changeset.valid?
    assert changeset |> get_change(:body) == "<p>A <strong>strong</strong> element</p>\n"
  end

  test "changeset requires markdown change" do
    changeset = Preview.changeset(%Preview{}, %{}, nil)
    refute changeset.valid?
    assert changeset.errors[:markdown] == {"can't be blank", []}
  end

  test "assings user_id if present" do
    user = insert_user
    changeset = Preview.changeset(%Preview{}, %{markdown: "A **strong** element"}, user)
    assert changeset.valid?
    assert Ecto.Changeset.get_change(changeset, :user).data == user
  end
end
