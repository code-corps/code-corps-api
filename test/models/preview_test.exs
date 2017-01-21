defmodule CodeCorps.PreviewTest do
  use CodeCorps.ModelCase

  alias CodeCorps.Preview

  describe "create_changeset/2" do
    test "renders body html from markdown" do
      user = insert(:user)
      changeset = Preview.create_changeset(%Preview{}, %{
        markdown: "A **strong** element",
        user_id: user.id
      })
      assert changeset.valid?
      assert changeset |> get_change(:body) == "<p>A <strong>strong</strong> element</p>\n"
    end

    test "requires markdown change" do
      changeset = Preview.create_changeset(%Preview{}, %{})
      refute changeset.valid?
      changeset |> assert_validation_triggered(:markdown, :required)
    end
  end
end
