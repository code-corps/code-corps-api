defmodule CodeCorps.Emails.APITest do
  @moduledoc false

  use ExUnit.Case, async: false

  alias CodeCorps.Emails.API

  describe "create_template/3" do
    test "works" do
      API.create_template(%{id: "id"}, "foo", "bar")
      assert_received({%{id: "id"}, "foo", "bar"})
    end
  end

  describe "update_template/4" do
    test "works" do
      API.update_template("id", "foo", "bar", "baz")
      assert_received({"id", "foo", "bar", "baz"})
    end
  end

  describe "send_transmission/1" do
    test "works" do
      API.send_transmission(%SparkPost.Transmission{recipients: []})
      assert_received(%SparkPost.Transmission{recipients: []})
    end
  end
end
