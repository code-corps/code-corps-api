defmodule CodeCorps.MapUtilsTest do
  use ExUnit.Case, async: true

  import CodeCorps.MapUtils, only: [keys_to_string: 1, rename: 3]

  test "&rename/3 renames old key in map to new key" do
    assert %{"foo" => 2} |> rename("foo", "bar") == %{"bar" => 2}
  end

  test "&keys_to_string/1 stringifies any keys in map" do
    assert %{:a => "one", :b => "two"} |> keys_to_string == %{"a" => "one", "b" => "two"}
    assert %{} |> keys_to_string == %{}
  end
end
