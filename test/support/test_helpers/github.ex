defmodule CodeCorps.TestHelpers.GitHub do
  @moduledoc """
  Contains test helpers for testing github features
  """

  @spec load_fixture(String.t) :: map
  def load_fixture(id) do
    "./test/fixtures/github_events/#{id}.json" |> File.read! |> Poison.decode!
  end
end
