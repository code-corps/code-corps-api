defmodule CodeCorps.Helpers.URLTest do
  use ExUnit.Case, async: true

  import CodeCorps.Helpers.URL

  alias Ecto.Changeset

  test "returns nil when nil" do
    changeset = create_prefixed_changeset(nil)
    assert Changeset.get_change(changeset, :url) == nil
  end

  test "returns the original when starts with http://" do
    original = "http://www.google.com"
    changeset = create_prefixed_changeset(original)
    assert Changeset.get_change(changeset, :url) == original
  end

  test "returns the original when starts with https://" do
    original = "https://www.google.com"
    changeset = create_prefixed_changeset(original)
    assert Changeset.get_change(changeset, :url) == original
  end

  test "returns prefixed with http:// in every other case" do
    changeset = create_prefixed_changeset("www.google.com")
    assert Changeset.get_change(changeset, :url) == "http://www.google.com"
  end

  defp create_prefixed_changeset(value) do
    %Changeset{changes: %{url: value}} |> prefix_url(:url)
  end
end
