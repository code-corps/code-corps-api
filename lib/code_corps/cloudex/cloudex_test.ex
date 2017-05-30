defmodule CloudexTest do
  @moduledoc """
  Testing stub for `Cloudex`,

  Each function should have the same signature as `Cloudex`.
  """

  defmodule Url do
    def for(_public_id, %{height: height, width: width}) do
      "https://placehold.it/#{width}x#{height}"
    end
    def for(_public_id, _options) do
      "https://placehold.it/500x500"
    end
  end
end
