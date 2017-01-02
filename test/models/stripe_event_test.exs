defmodule CodeCorps.StripeEventTest do
  use CodeCorps.ModelCase

  alias CodeCorps.StripeEvent

  describe "create_changeset/2" do
    @valid_attrs %{endpoint: "connect", id_from_stripe: "evt_123", type: "any.event"}

    test "reports as valid when attributes are valid" do
      changeset = StripeEvent.create_changeset(%StripeEvent{}, @valid_attrs)
      assert changeset.valid?
    end

    test "requires :id_from_stripe, :type" do
      changeset = StripeEvent.create_changeset(%StripeEvent{}, %{})

      refute changeset.valid?
      assert_error_message(changeset, :endpoint, "can't be blank")
      assert_error_message(changeset, :id_from_stripe, "can't be blank")
      assert_error_message(changeset, :type, "can't be blank")
    end

    test "sets :status to 'processing'" do
      {:ok, %StripeEvent{} = record} =
        %StripeEvent{}
        |> StripeEvent.create_changeset(@valid_attrs)
        |> Repo.insert

      assert record.status == "processing"
    end

    test "prevents :endpoint from being invalid" do
      event = insert(:stripe_event)

      attrs = %{endpoint: "random", id_from_stripe: "evt_123", type: "any.event"}
      changeset = StripeEvent.create_changeset(event, attrs)

      refute changeset.valid?
      assert_error_message(changeset, :endpoint, "is invalid")
    end
  end

  describe "update_changeset/2" do
    @valid_attrs %{status: "unprocessed"}

    test "reports as valid when attributes are valid" do
      event = insert(:stripe_event)

      changeset = StripeEvent.update_changeset(event, @valid_attrs)
      assert changeset.valid?
    end

    test "requires :status" do
      event = insert(:stripe_event)

      changeset = StripeEvent.update_changeset(event, %{status: nil})

      refute changeset.valid?
      assert_error_message(changeset, :status, "can't be blank")
    end

    test "prevents :status from being invalid" do
      event = insert(:stripe_event)

      changeset = StripeEvent.update_changeset(event, %{status: "random"})

      refute changeset.valid?
      assert_error_message(changeset, :status, "is invalid")
    end
  end
end
