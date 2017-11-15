defmodule CodeCorps.GitHub.Webhook.EventSupportTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias CodeCorps.GitHub.Webhook.EventSupport

  test "supported_events/0 returns a list of supported events" do
    assert EventSupport.supported_events |> is_list
  end

  test "unsupported_events/0 returns a list of unsupported events" do
    assert EventSupport.unsupported_events |> is_list
  end

  describe "status/1" do
    test "returns :supported for all supported events" do
      EventSupport.supported_events |> Enum.each(fn {type, action} ->
        assert EventSupport.status(type, action) == :supported
      end)
    end

    test "returns :unsupported for all unsupported events" do
      EventSupport.unsupported_events |> Enum.each(fn {type, action} ->
        assert EventSupport.status(type, action) == :unsupported
      end)
    end

    test "returns :ignored for any other event" do
      assert EventSupport.status("foo", "bar") == :ignored
    end
  end
end
