defmodule CodeCorps.GitHub.Event.InstallationRepositories.ValidatorTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.GitHub.Event.InstallationRepositories.Validator

  describe "valid?/1" do
    test "returns true for any Issues event fixture" do
      assert "installation_repositories_added" |> load_event_fixture() |> Validator.valid?
      assert "installation_repositories_removed" |> load_event_fixture() |> Validator.valid?
    end

    test "returns false for an unsupported structure" do
      refute Validator.valid?("foo")
      refute Validator.valid?(%{"action" => "foo", "foo" => "bar"})
      refute Validator.valid?(%{"action" => "foo", "installation" => %{"bar" => "baz"}})
      refute Validator.valid?(%{"action" => "added", "installation" => %{"id" => "foo"}, "repositories_added" => [%{"id" => "foo"}]})
      refute Validator.valid?(%{"action" => "removed", "installation" => %{"id" => "foo"}, "repositories_removed" => [%{"id" => "ba"}]})
      refute Validator.valid?(%{"action" => "added", "installation" => %{"id" => "foo"}, "repositories_added" => ["foo"]})
      refute Validator.valid?(%{"action" => "removed", "installation" => %{"id" => "foo"}, "repositories_removed" => ["bar"]})
      refute Validator.valid?(%{"action" => "added", "installation" => %{"id" => "foo"}, "repositories_added" => "foo"})
      refute Validator.valid?(%{"action" => "removed", "installation" => %{"id" => "foo"}, "repositories_removed" => "bar"})
    end
  end
end
