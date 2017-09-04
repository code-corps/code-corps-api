defmodule CodeCorps.GitHub.Event.Installation.ValidatorTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.GitHub.Event.Installation.Validator

  describe "valid?/1" do
    test "returns true for any Installation event fixture" do
      assert "installation_created" |> load_event_fixture() |> Validator.valid?
    end

    test "returns false for an unsupported structure" do
      refute Validator.valid?("foo")
      refute Validator.valid?(%{"foo" => "bar"})
      refute Validator.valid?(%{"installation" => %{"bar" => "baz"}})
      refute Validator.valid?(%{"sender" => %{"bar" => "baz"}})
    end
  end
end
