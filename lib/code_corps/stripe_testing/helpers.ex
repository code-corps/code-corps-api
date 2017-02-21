defmodule CodeCorps.StripeTesting.Helpers do
  @moduledoc """
  Used to load JSON fitures which simulate Stripe API responses into
  stripity_stripe structs
  """
  @fixture_path "./lib/code_corps/stripe_testing/fixtures/"

  @doc """
  Load a stripe response fixture through stripity_stripe, into a
  stripity_stripe struct
  """
  @spec load_fixture(String.t) :: struct
  def load_fixture(id) do
    fixture_map = id |> build_file_path |> File.read! |> Poison.decode!
    Stripe.Converter.stripe_map_to_struct(fixture_map)
  end

  defp build_file_path(id), do: id |> append_extension |> join_with_path
  defp append_extension(id), do: id <> ".json"
  defp join_with_path(filename), do: @fixture_path <> filename
end
