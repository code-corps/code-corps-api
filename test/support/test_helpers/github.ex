defmodule CodeCorps.TestHelpers.GitHub do
  @moduledoc """
  Contains test helpers for testing github features
  """

  @spec load_endpoint_fixture(String.t) :: map
  def load_endpoint_fixture(id) do
    "./test/fixtures/github/endpoints/#{id}.json" |> File.read! |> Poison.decode!
  end

  @spec load_event_fixture(String.t) :: map
  def load_event_fixture(id) do
    "./test/fixtures/github/events/#{id}.json" |> File.read! |> Poison.decode!
  end
end
