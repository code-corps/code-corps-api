defmodule CodeCorps.StripeTesting.Event do
  def retrieve(id, _opts = [connect_account: _]) do
    {:ok, do_retrieve_connect(id)}
  end
  def retrieve(id) do
    {:ok, do_retrieve(id)}
  end

  defp do_retrieve(_) do

    %Stripe.Event{
      api_version: "2016-07-06",
      created: 1479472835,
      id: "evt_123",
      livemode: false,
      object: "event",
      pending_webhooks: 1,
      request: nil,
      type: "any.event"
    }
  end

  defp do_retrieve_connect(_) do
    %Stripe.Event{
      api_version: "2016-07-06",
      created: 1479472835,
      id: "evt_123",
      livemode: false,
      object: "event",
      pending_webhooks: 1,
      request: nil,
      type: "any.event",
      user_id: "acct_123"
    }
  end
end
