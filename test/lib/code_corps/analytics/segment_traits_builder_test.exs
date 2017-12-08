defmodule CodeCorps.Analytics.SegmentTraitsBuilderTest do
  @moduledoc false

  use CodeCorps.DbAccessCase


  alias CodeCorps.Analytics.SegmentTraitsBuilder

  describe "build/1" do
    # NOTE: These tests only make sure there's a function clause for each
    # supported struct and do not assert the traits content. Simply put, the
    # only way to assert that would mean we're practically re-implementing the
    # builder within tests

    test "works for all supported struct types" do
      assert :comment |> insert |> SegmentTraitsBuilder.build
      assert :donation_goal |> insert |> SegmentTraitsBuilder.build

      assert :github_app_installation |> insert |> SegmentTraitsBuilder.build
      assert :github_repo |> insert |> SegmentTraitsBuilder.build

      assert :project |> insert |> SegmentTraitsBuilder.build
      assert :project_skill |> insert |> SegmentTraitsBuilder.build
      assert :project_user |> insert |> SegmentTraitsBuilder.build

      assert :stripe_connect_account |> insert |> SegmentTraitsBuilder.build
      assert :stripe_connect_charge |> insert |> SegmentTraitsBuilder.build
      assert :stripe_connect_plan |> insert |> SegmentTraitsBuilder.build
      assert :stripe_connect_subscription |> insert |> SegmentTraitsBuilder.build
      assert :stripe_platform_card |> insert |> SegmentTraitsBuilder.build
      assert :stripe_platform_customer |> insert |> SegmentTraitsBuilder.build

      assert :task |> insert |> SegmentTraitsBuilder.build
      assert :task_skill |> insert |> SegmentTraitsBuilder.build

      assert :user |> insert |> SegmentTraitsBuilder.build
      assert :user_category |> insert |> SegmentTraitsBuilder.build
      assert :user_role |> insert |> SegmentTraitsBuilder.build
      assert :user_skill |> insert |> SegmentTraitsBuilder.build
      assert :user_task |> insert |> SegmentTraitsBuilder.build

      assert %{token: "foo", user_id: 1} |> SegmentTraitsBuilder.build
    end
  end
end
