defmodule CodeCorps.StripeAuthView do
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:url]

  @doc """
  Since this view does not represent a record, the `id` is manually
  set to `"1"`.
  """
  def id(_struct, _conn), do: "1"
end
