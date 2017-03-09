defmodule CodeCorps.Helpers.URL do
  @moduledoc """
  Provides some helpers for assembling and validating URLs.
  """

  alias Ecto.Changeset

  @doc """
  Prefixes the URL with `http://` in the event that `http://` and `https://` are
  not already the starting format. If `nil`, simply returns `nil`.
  """
  def prefix_url(changeset, key) do
    changeset
    |> Changeset.update_change(key, &do_prefix_url/1)
  end

  defp do_prefix_url(nil), do: nil
  defp do_prefix_url("http://" <> rest), do: "http://" <> rest
  defp do_prefix_url("https://" <> rest), do: "https://" <> rest
  defp do_prefix_url(value), do: "http://" <> value

  def valid_format do
    ~r/\A((http|https):\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,}(([0-9]{1,5})?\/.*)?#=\z/ix
  end
end
