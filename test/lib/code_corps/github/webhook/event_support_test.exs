defmodule CodeCorps.GitHub.Webhook.EventSupportTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias CodeCorps.GitHub.Webhook.EventSupport

  test "supported_events/0 returns a list of supported events" do
    assert EventSupport.supported_events |> is_list
  end

  describe "status/1" do
    test "returns :supported for all supported events" do
      EventSupport.supported_events |> Enum.each(fn event ->
        assert EventSupport.status(event) == :supported
      end)
    end

    test "returns :unsupported for any other event" do
      assert EventSupport.status("foo") == :unsupported
    end
  end
end
