defmodule CodeCorps.StripeService.WebhookProcessing.EventHandlerTest do
  use CodeCorps.ModelCase

  alias CodeCorps.StripeService.WebhookProcessing.{
    ConnectEventHandler, EventHandler, PlatformEventHandler
  }

  alias CodeCorps.{
    Repo, Project,
    StripeEvent, StripeInvoice, StripePlatformCard, StripePlatformCustomer,
    StripeTesting
  }

  defmodule CodeCorps.StripeService.WebhookProcessing.EventHandlerTest.StubObject do
    defstruct [:id, :object]
  end

  defp stub_object() do
    %CodeCorps.StripeService.WebhookProcessing.EventHandlerTest.StubObject{id: "stub_id", object: "stub"}
  end

  defp build_event(user_id), do: build_event("any.event", "any_object", user_id)
  defp build_event(type, object_type, user_id), do: build_event(type, object_type, stub_object(), user_id)
  defp build_event(type, object_type, object, user_id), do: build_event("some_id", type, object_type, object, user_id)
  defp build_event(id, type, object_type, object, user_id) do
    object = Map.merge(object, %{object: object_type})
    %Stripe.Event{id: id, type: type, data: %{object: object}, user_id: user_id}
  end

  describe "platform events" do
    test "handles customer.updated" do
      platform_customer = insert(:stripe_platform_customer)
      stripe_customer = %Stripe.Customer{id: platform_customer.id_from_stripe}
      event = build_event("customer.updated", "customer", stripe_customer, nil)

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
      event = build_event("customer.source.updated", "card", stripe_card, nil)

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
    test "handles account.updated" do
      connect_account = insert(:stripe_connect_account)
      event = build_event(
        "account.updated",
        "account",
        %Stripe.Account{id: connect_account.id_from_stripe},
        connect_account.id_from_stripe
      )

      {:ok, event} = EventHandler.handle(event, ConnectEventHandler, "acc_123")
      assert event.object_type == "account"
      assert event.object_id == connect_account.id_from_stripe
      assert event.status == "processed"
      assert event.user_id == "acc_123"
    end

    test "handles charge.succeeded as processed when everything is in order" do
      connect_account = insert(:stripe_connect_account)

      charge_fixture = StripeTesting.Helpers.load_fixture(Stripe.Charge, "charge")
      insert(:stripe_connect_customer, id_from_stripe: charge_fixture.customer)

      invoice_fixture = StripeTesting.Helpers.load_fixture(Stripe.Invoice, charge_fixture.invoice)
      insert(:stripe_connect_subscription, id_from_stripe: invoice_fixture.subscription)

      project = Repo.one(Project)
      insert(:donation_goal, current: true, project: project)

      event = build_event("charge.succeeded", "charge", charge_fixture, connect_account.id_from_stripe)

      {:ok, event} = EventHandler.handle(event, ConnectEventHandler, connect_account.id_from_stripe)
      assert event.object_type == "charge"
      assert event.object_id == charge_fixture.id
      assert event.status == "processed"
    end

    test "handles charge.succeeded as errored when something goes wrong with email" do
      connect_account = insert(:stripe_connect_account)
      charge_fixture = StripeTesting.Helpers.load_fixture(Stripe.Charge, "charge")

      insert(:stripe_connect_customer, id_from_stripe: charge_fixture.customer)

      event = build_event("charge.succeeded", "charge", charge_fixture, connect_account.id_from_stripe)
      {:ok, event} = EventHandler.handle(event, ConnectEventHandler, connect_account.id_from_stripe)

      assert event.object_type == "charge"
      assert event.object_id == charge_fixture.id
      assert event.status == "errored"
    end

    test "handles charge.succeeded as errored when something goes wrong with creating a charge" do
      charge_fixture = StripeTesting.Helpers.load_fixture(Stripe.Charge, "charge")

      event = build_event("charge.succeeded", "charge", charge_fixture, "bad_account")
      {:ok, event} = EventHandler.handle(event, ConnectEventHandler, "bad_account")

      assert event.object_type == "charge"
      assert event.object_id == charge_fixture.id
      assert event.status == "errored"
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
        "subscription",
        %Stripe.Subscription{
          id: subscription.id_from_stripe,
          customer: connect_customer.id_from_stripe
        },
        account.id_from_stripe
      )

      {:ok, event} = EventHandler.handle(event, ConnectEventHandler, "acc_123")
      assert event.object_type == "subscription"
      assert event.object_id == subscription.id_from_stripe
      assert event.status == "processed"
      assert event.user_id == "acc_123"
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
        "subscription",
        %Stripe.Subscription{
          id: subscription.id_from_stripe,
          customer: connect_customer.id_from_stripe
        },
        account.id_from_stripe
      )

      {:ok, event} = EventHandler.handle(event, ConnectEventHandler, "acc_123")
      assert event.object_type == "subscription"
      assert event.object_id == subscription.id_from_stripe
      assert event.status == "processed"
      assert event.user_id == "acc_123"
    end

    test "handles invoice.payment_succeeded" do
      fixture = StripeTesting.Helpers.load_fixture(Stripe.Invoice, "invoice")

      insert(:stripe_connect_subscription, id_from_stripe: fixture.subscription)

      user = insert(:user)
      stripe_platform_customer = insert(:stripe_platform_customer, user: user)
      # same with hardcoding customer id from stripe
      insert(
        :stripe_connect_customer,
        id_from_stripe: fixture.customer,
        stripe_platform_customer: stripe_platform_customer,
        user: user
      )

      event = build_event("invoice.payment_succeeded", "invoice", fixture, nil)

      {:ok, event} = EventHandler.handle(event, ConnectEventHandler, "acc_123")
      assert event.object_type == "invoice"
      assert event.object_id == fixture.id
      assert event.status == "processed"
      assert event.user_id == "acc_123"

      assert Repo.get_by(StripeInvoice, id_from_stripe: fixture.id)
    end
  end

  describe "any event" do
    test "sets endpoint to 'platform' when using PlatformEventHandler" do
      event = build_event(nil)

      {:ok, event} = EventHandler.handle(event, PlatformEventHandler)
      assert event.endpoint == "platform"
      assert event.user_id == nil
    end

    test "sets endpoint to 'connect' when using ConnectEventHandler" do
      event = build_event(nil)

      {:ok, event} = EventHandler.handle(event, ConnectEventHandler, "acc_123")
      assert event.endpoint == "connect"
      assert event.user_id == "acc_123"
    end

    test "creates event if id is new" do
      event = build_event(nil)
      {:ok, event} = EventHandler.handle(event, PlatformEventHandler)

      assert event.id_from_stripe == "some_id"
      assert event.object_id == "stub_id"
      assert event.object_type == "any_object"
      assert event.status == "unhandled"
      assert event.user_id == nil
    end

    test "uses existing event if id exists" do
      local_event = insert(:stripe_event)
      event = build_event(local_event.id_from_stripe, "any.event", "any_object", stub_object(), nil)

      {:ok, returned_event} = EventHandler.handle(event, PlatformEventHandler)
      assert returned_event.id == local_event.id

      assert StripeEvent |> Repo.aggregate(:count, :id) == 1
    end

    test "sets event as unhandled if event is not handled" do
      event = build_event("unhandled.event", "any_object", nil)

      {:ok, event} = EventHandler.handle(event, PlatformEventHandler)
      assert event.status == "unhandled"
    end

    test "errors out event if handling fails" do
      # we build the event, but do not make the customer, causing it to error out
      event = build_event("customer.updated", "customer", %Stripe.Customer{id: "some_id"}, nil)

      {:ok, event} = EventHandler.handle(event, PlatformEventHandler)
      assert event.status == "errored"
    end

    test "marks event as processed if handling is done" do
      # we build the event AND create the customer, so it should process correctly
      event = build_event("customer.updated", "customer", %Stripe.Customer{id: "some_id"}, nil)
      insert(:stripe_platform_customer, id_from_stripe: "some_id")

      {:ok, event} = EventHandler.handle(event, PlatformEventHandler)
      assert event.status == "processed"
    end

    test "leaves event alone if already processing" do
      local_event = insert(:stripe_event, status: "processing")
      event = build_event(local_event.id_from_stripe, "any.event", "any_object", %Stripe.Customer{id: "some_id"}, nil)

      assert {:error, :already_processing} == EventHandler.handle(event, PlatformEventHandler)
    end
  end

  describe "ignored events" do
    test "properly sets as ignored" do
      event = build_event("application_fee.created", "application_fee", nil)
      {:ok, event} = EventHandler.handle(event, PlatformEventHandler)

      assert event.status == "ignored"
      assert event.ignored_reason
    end
  end
end
