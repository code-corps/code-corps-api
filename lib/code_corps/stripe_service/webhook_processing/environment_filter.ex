defmodule CodeCorps.StripeService.WebhookProcessing.EnvironmentFilter do
  @moduledoc """
  Used to filter events based on environment
  """

  @doc """
  Returns true if the livemode attribute of the event matches
  the current environment of the Phoenix application.

  - livemode events are processed only in production.
  - non-livemode events are processed in all other environments
  """
  def environment_matches?(%{"livemode" => livemode}) do
    case Application.get_env(:code_corps, :stripe_env) do
      :prod -> livemode
      _ -> !livemode
    end
  end
end
