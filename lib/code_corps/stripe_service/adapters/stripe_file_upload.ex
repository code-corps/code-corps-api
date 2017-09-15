defmodule CodeCorps.StripeService.Adapters.StripeFileUploadAdapter do
  @moduledoc """
  Used for conversion between stripe api payload maps and maps
  usable for creation of `StripeFileUpload` records locally
  """

  import CodeCorps.MapUtils, only: [rename: 3, keys_to_string: 1]

  @stripe_attributes [:created, :id, :purpose, :size, :type]

  @doc """
  Converts a struct received from the Stripe API into a map that can be used
  to create a `CodeCorps.StripeFileUpload` record
  """
  def to_params(%Stripe.FileUpload{} = stripe_file_upload, %{} = attributes) do
    result =
      stripe_file_upload
      |> Map.from_struct
      |> Map.take(@stripe_attributes)
      |> rename(:id, :id_from_stripe)
      |> keys_to_string
      |> add_non_stripe_attributes(attributes)

    {:ok, result}
  end

  @non_stripe_attributes ["stripe_connect_account_id"]

  defp add_non_stripe_attributes(%{} = params, %{} = attributes) do
    attributes
    |> get_non_stripe_attributes
    |> add_to(params)
  end

  defp get_non_stripe_attributes(%{} = attributes) do
    attributes
    |> Map.take(@non_stripe_attributes)
  end

  defp add_to(%{} = attributes, %{} = params) do
    params
    |> Map.merge(attributes)
  end
end
