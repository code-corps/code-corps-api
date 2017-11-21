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
    id
    |> load_raw_fixture()
    |> Stripe.Converter.convert_result
  end

  @spec load_raw_fixture(String.t) :: map
  def load_raw_fixture(id) do
    id
    |> build_file_path
    |> File.read!
    |> Poison.decode!
  end

  defp build_file_path(id), do: id |> append_extension |> join_with_path
  defp append_extension(id), do: id <> ".json"
  defp join_with_path(filename), do: @fixture_path <> filename
end
