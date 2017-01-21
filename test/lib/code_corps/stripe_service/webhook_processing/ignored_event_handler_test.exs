defmodule CodeCorps.StripeService.WebhookProcessing.IgnoredEventHandlerTest do
  use CodeCorps.ModelCase

  alias CodeCorps.StripeService.WebhookProcessing.{
    ConnectEventHandler, IgnoredEventHandler, PlatformEventHandler
  }

  @spec ignored?(String.t, Module.t) :: boolean
  defp ignored?(type, handler) do
    event = insert(:stripe_event, type: type)
    {:ok, event} = IgnoredEventHandler.handle(event, handler)

    event.ignored_reason && event.status == "ignored"
  end

  describe "handle/2" do
    test "ignores events from the ignored platform events list" do
      IgnoredEventHandler.ignored_event_types(PlatformEventHandler)
      |> Enum.each(fn(type) -> assert ignored?(type, PlatformEventHandler) end)

      assert_raise(FunctionClauseError, fn -> ignored?("some.other.type", PlatformEventHandler) end)
    end

    test "ignores events from the ignored connect events list" do
      IgnoredEventHandler.ignored_event_types(ConnectEventHandler)
      |> Enum.each(fn(type) -> assert ignored?(type, ConnectEventHandler) end)

      assert_raise(FunctionClauseError, fn -> ignored?("some.other.type", ConnectEventHandler) end)
    end
  end

  describe "should_handle?/2" do
    test "returns true for types from the ignored platform events list" do
      IgnoredEventHandler.ignored_event_types(PlatformEventHandler)
      |> Enum.each(fn(type) -> assert IgnoredEventHandler.should_handle?(type, PlatformEventHandler) end)

      refute IgnoredEventHandler.should_handle?("some.other.type", PlatformEventHandler)
    end

    test "returns true for types from the ignored connect events list" do
      IgnoredEventHandler.ignored_event_types(ConnectEventHandler)
      |> Enum.each(fn(type) -> assert IgnoredEventHandler.should_handle?(type, ConnectEventHandler) end)

      refute IgnoredEventHandler.should_handle?("some.other.type", ConnectEventHandler)
    end
  end
 end
