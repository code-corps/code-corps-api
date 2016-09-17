defmodule CodeCorps.RandomIconColor.TestGeneratorTest do
  use ExUnit.Case, async: true

  alias CodeCorps.RandomIconColor.TestGenerator

  @colors ~w(blue green light_blue pink purple yellow)

  test "generates random icon color" do
    assert Enum.member?(@colors, TestGenerator.generate)
  end
end
