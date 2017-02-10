defmodule CodeCorps.StripeService.Adapters.StripeEventAdapter do
  @moduledoc """
  Handles data transformations between the API `Stripe.Event` struct and maps of
  attributes suitable for work with our own `StripeEvent` database objects.
  """
  import CodeCorps.MapUtils, only: [keys_to_string: 1]
  import CodeCorps.StripeService.Util, only: [transform_map: 2]

  # Mapping of stripe record attributes to locally stored attributes
  # Format is {:local_key, [:nesting, :of, :stripe, :keys]}
  @stripe_mapping [
    {:id_from_stripe, [:id]},
    {:type, [:type]},
    {:user_id, [:user_id]}
  ]

  @doc """
  Transforms a `%Stripe.Event{}` and a set of local attributes into a
  map of parameters used to create or update a `StripeEvent` record.
  """
  @spec to_params(Stripe.Event.t, map) :: {:ok, map}
  def to_params(%Stripe.Event{} = stripe_event, %{} = attributes) do
    result =
      stripe_event
      |> Map.from_struct
      |> transform_map(@stripe_mapping)
      |> add_non_stripe_attributes(attributes)
      |> add_object_type(stripe_event)
      |> add_object_id(stripe_event)
      |> keys_to_string

    {:ok, result}
  end

  # Names of attributes which we need to store localy,
  # but are not part of the Stripe API record
  @non_stripe_attributes ["endpoint", "status"]

  defp add_non_stripe_attributes(%{} = params, %{} = attributes) do
    attributes
    |> get_non_stripe_attributes
    |> add_to(params)
  end

  defp get_non_stripe_attributes(%{} = attributes) do
    attributes |> Map.take(@non_stripe_attributes)
  end

  defp add_to(%{} = attributes, %{} = params) do
    params |> Map.merge(attributes)
  end

  # NOTE: unlike object_id, object_type should never be nil
  # Due to that, we do not have a catch-all clause for the nil case
  # If it ever is nil, it should fail and we should know about it
  defp add_object_type(params, %{data: %{object: %{object: object}}}), do: params |> Map.put(:object_type, object)

  defp add_object_id(params, %{data: %{object: %{id: id}}}), do: params |> Map.put(:object_id, id)
  defp add_object_id(params, _stripe_event), do: params |> Map.put(:object_id, nil)
end
