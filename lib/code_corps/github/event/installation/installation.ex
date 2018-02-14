defmodule CodeCorps.GitHub.Event.Installation do
  @moduledoc """
  In charge of handling a GitHub Webhook payload for the Installation event type
  [https://developer.github.com/v3/activity/events/types/#installationevent](https://developer.github.com/v3/activity/events/types/#installationevent)
  """

  @behaviour CodeCorps.GitHub.Event.Handler

  alias CodeCorps.{GitHub.Sync, GitHub.Event.Installation}


  @doc """
  Handles the "Installation" GitHub Webhook event.

  This is done by first validating the payload is in the format the system
  expects, followed by piping it into

  `CodeCorps.GitHub.Sync.installation_event/1`
  """
  @spec handle(map) ::
    Sync.installation_event_outcome() | {:error, :unexpected_payload}
  def handle(payload) do
    with {:ok, :valid} <- payload |> validate_payload() do
      Sync.installation_event(payload)
    else
      {:error, :invalid} -> {:error, :unexpected_payload}
    end
  end

  @spec validate_payload(map) :: {:ok, :valid} | {:error, :invalid}
  defp validate_payload(%{} = payload) do
    case payload |> Installation.Validator.valid? do
      true -> {:ok, :valid}
      false -> {:error, :invalid}
    end
  end
end
