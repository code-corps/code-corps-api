defmodule CodeCorps.StripeService.WebhookProcessing.IgnoredEventHandlerTest do
  use CodeCorps.ModelCase

  alias CodeCorps.StripeService.WebhookProcessing.IgnoredEventHandler

  defp ignored?(type) do
    event = insert(:stripe_event, type: type)
    {:ok, event} = IgnoredEventHandler.handle(event)

    event.ignored_reason && event.status == "ignored"
  end

  describe "handle/1" do
    test "ignores events from the ignored events list" do
      IgnoredEventHandler.ignored_event_types
      |> Enum.each(fn(type) -> assert ignored?(type) end)

      assert_raise(FunctionClauseError, fn -> ignored?("some.other.type") end)
    end
  end

  describe "should_handle?/1" do
    test "returns true for types from the ignored list" do
      IgnoredEventHandler.ignored_event_types
      |> Enum.each(fn(type) -> assert IgnoredEventHandler.should_handle?(type) end)

      refute IgnoredEventHandler.should_handle?("some.other.type")
    end
  end
 end
