defmodule CodeCorps.StripeService.WebhookProcessing.EventHandlerTest do
  use CodeCorps.ModelCase

  alias CodeCorps.StripeService.WebhookProcessing.{
    ConnectEventHandler, EventHandler, PlatformEventHandler
  }

  alias CodeCorps.{
    StripeEvent, StripeExternalAccount, StripeInvoice, StripePlatformCard, StripePlatformCustomer
  }

  defmodule CodeCorps.StripeService.WebhookProcessing.EventHandlerTest.StubObject do
    defstruct [:id]
  end

  defp stub_object do
    %CodeCorps.StripeService.WebhookProcessing.EventHandlerTest.StubObject{id: "stub_id"}
  end

  defp build_event, do: build_event("any.event")
  defp build_event(type), do: build_event(type, stub_object)
  defp build_event(type, object), do: build_event("some_id", type, object)
  defp build_event(id, type, object), do: %Stripe.Event{id: id, type: type, data: %{object: object}}

  describe "platform events" do
    test "handles customer.updated" do
      platform_customer = insert(:stripe_platform_customer)
      stripe_customer = %Stripe.Customer{id: platform_customer.id_from_stripe}
      event = build_event("customer.updated", stripe_customer)

      {:ok, event} = EventHandler.handle(event, PlatformEventHandler)
      assert event.object_type == "customer"
      assert event.object_id == platform_customer.id_from_stripe
      assert event.status == "processed"

      platform_customer = Repo.get(StripePlatformCustomer, platform_customer.id)

      # hardcoded in StripeTesting.Customer
      assert platform_customer.email == "hardcoded@test.com"
    end

    test "handles customer.source.updated" do
      platform_customer = insert(:stripe_platform_customer)
      platform_card = insert(:stripe_platform_card, customer_id_from_stripe: platform_customer.id_from_stripe)
      stripe_card = %Stripe.Card{id: platform_card.id_from_stripe}
      event = build_event("customer.source.updated", stripe_card)

      {:ok, event} = EventHandler.handle(event, PlatformEventHandler)
      assert event.object_type == "card"
      assert event.object_id == platform_card.id_from_stripe
      assert event.status == "processed"

      updated_card = Repo.get_by(StripePlatformCard, id: platform_card.id)

      # hardcoded in StripeTesting.Card
      assert updated_card.name == "John Doe"
    end
  end

  describe "connect events" do
    test "handles account.external_account.created" do
      connect_account = insert(:stripe_connect_account)
      event = build_event(
        "account.external_account.created",
        %Stripe.ExternalAccount{id: "ext_123", account: connect_account.id_from_stripe}
      )

      {:ok, event} = EventHandler.handle(event, ConnectEventHandler)
      assert event.object_type == "external_account"
      assert event.object_id == "ext_123"
      assert event.status == "processed"

      assert Repo.get_by(StripeExternalAccount, id_from_stripe: "ext_123")
    end

    test "handles account.updated" do
      connect_account = insert(:stripe_connect_account)
      event = build_event("account.updated", %Stripe.Account{id: connect_account.id_from_stripe})

      {:ok, event} = EventHandler.handle(event, ConnectEventHandler)
      assert event.object_type == "account"
      assert event.object_id == connect_account.id_from_stripe
      assert event.status == "processed"
    end

    test "handles customer.subscription.updated" do
      project = insert(:project)
      plan = insert(:stripe_connect_plan, project: project)
      subscription = insert(:stripe_connect_subscription, stripe_connect_plan: plan)

      account = insert(:stripe_connect_account)
      platform_customer = insert(:stripe_platform_customer)
      connect_customer = insert(
        :stripe_connect_customer,
        stripe_connect_account: account,
        stripe_platform_customer: platform_customer
      )

      event = build_event(
        "customer.subscription.updated",
        %Stripe.Subscription{
          id: subscription.id_from_stripe,
          customer: connect_customer.id_from_stripe
        }
      )

      {:ok, event} = EventHandler.handle(event, ConnectEventHandler)
      assert event.object_type == "subscription"
      assert event.object_id == subscription.id_from_stripe
      assert event.status == "processed"
    end

    test "handles customer.subscription.deleted" do
      project = insert(:project)
      plan = insert(:stripe_connect_plan, project: project)
      subscription = insert(:stripe_connect_subscription, stripe_connect_plan: plan)

      account = insert(:stripe_connect_account)
      platform_customer = insert(:stripe_platform_customer)
      connect_customer = insert(
        :stripe_connect_customer,
        stripe_connect_account: account,
        stripe_platform_customer: platform_customer
      )

      event = build_event(
        "customer.subscription.deleted",
        %Stripe.Subscription{
          id: subscription.id_from_stripe,
          customer: connect_customer.id_from_stripe
        }
      )

      {:ok, event} = EventHandler.handle(event, ConnectEventHandler)
      assert event.object_type == "subscription"
      assert event.object_id == subscription.id_from_stripe
      assert event.status == "processed"
    end

    test "handles invoice.payment_succeeded" do
      user = insert(:user)
      # need to hardcode id from stripe, since this is the value StripeTesting returns
      subscription = insert(:stripe_connect_subscription, id_from_stripe: "sub_123")
      stripe_platform_customer = insert(:stripe_platform_customer, user: user)
      # same with hardcoding customer id from stripe
      connect_customer = insert(
        :stripe_connect_customer,
        id_from_stripe: "cus_123",
        stripe_platform_customer: stripe_platform_customer,
        user: user
      )

      event = build_event(
        "invoice.payment_succeeded",
        %Stripe.Invoice{
          id: "ivc_123",
          customer: connect_customer.id_from_stripe,
          subscription: subscription.id_from_stripe
        }
      )

      {:ok, event} = EventHandler.handle(event, ConnectEventHandler)
      assert event.object_type == "invoice"
      assert event.object_id == "ivc_123"
      assert event.status == "processed"

      assert Repo.get_by(StripeInvoice, id_from_stripe: "ivc_123")
    end
  end

  describe "any event" do
    test "sets endpoint to 'platform' when using PlatformEventHandler" do
      event = build_event

      {:ok, event} = EventHandler.handle(event, PlatformEventHandler)
      assert event.endpoint == "platform"
    end

    test "sets endpoint to 'connect' when using ConnectEventHandler" do
      event = build_event

      {:ok, event} = EventHandler.handle(event, ConnectEventHandler)
      assert event.endpoint == "connect"
    end

    test "creates event if id is new" do
      event = build_event
      {:ok, event} = EventHandler.handle(event, PlatformEventHandler)

      assert event.id_from_stripe == "some_id"
      assert event.object_id == "stub_id"
      assert event.object_type == "stub_object"
      assert event.status == "unhandled"
    end

    test "uses existing event if id exists" do
      local_event = insert(:stripe_event)
      event = build_event(local_event.id_from_stripe, "any.event", stub_object)

      {:ok, returned_event} = EventHandler.handle(event, PlatformEventHandler)
      assert returned_event.id == local_event.id

      assert StripeEvent |> Repo.aggregate(:count, :id) == 1
    end

    test "sets event as unhandled if event is not handled" do
      event = build_event("unhandled.event")

      {:ok, event} = EventHandler.handle(event, PlatformEventHandler)
      assert event.status == "unhandled"
    end

    test "errors out event if handling fails" do
      # we build the event, but do not make the customer, causing it to error out
      event = build_event("customer.updated", %Stripe.Customer{id: "some_id"})

      {:ok, event} = EventHandler.handle(event, PlatformEventHandler)
      assert event.status == "errored"
    end

    test "marks event as processed if handling is done" do
      # we build the event AND create the customer, so it should process correctly
      event = build_event("customer.updated", %Stripe.Customer{id: "some_id"})
      insert(:stripe_platform_customer, id_from_stripe: "some_id")

      {:ok, event} = EventHandler.handle(event, PlatformEventHandler)
      assert event.status == "processed"
    end

    test "leaves event alone if already processing" do
      local_event = insert(:stripe_event, status: "processing")
      event = build_event(local_event.id_from_stripe, "any.event", %Stripe.Customer{id: "some_id"})

      assert {:error, :already_processing} == EventHandler.handle(event, PlatformEventHandler)
    end
  end
end
