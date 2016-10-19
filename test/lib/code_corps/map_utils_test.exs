defmodule CodeCorps.MapUtilsTest do
  use ExUnit.Case, async: true

  import CodeCorps.MapUtils, only: [rename: 3]

  test "&rename/3 renames old key in map to new key" do
    assert %{"foo" => 2} |> rename("foo", "bar") == %{"bar" => 2}
  end
end
