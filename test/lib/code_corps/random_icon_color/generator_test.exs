defmodule CodeCorps.RandomIconColor.GeneratorTest do
  use ExUnit.Case, async: true

  alias CodeCorps.RandomIconColor.Generator

  @colors ~w(blue green light_blue pink purple yellow)

  test "generates random icon color" do
    assert Enum.member?(@colors, Generator.generate)
  end
end
