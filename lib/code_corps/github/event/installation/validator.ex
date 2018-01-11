defmodule CodeCorps.GitHub.Event.Installation.Validator do
  @moduledoc ~S"""
  In charge of validatng a GitHub.API.Installation webhook payload.

  https://developer.github.com/v3/activity/events/types/#installationevent
  """

  @behaviour CodeCorps.GitHub.Event.Validator

  @doc ~S"""
  Returns `true` if all keys required to properly handle an Installation webhook
  are present in the provided payload.
  """
  @impl CodeCorps.GitHub.Event.Validator
  @spec valid?(map) :: boolean
  def valid?(%{
    "action" => _,
    "installation" => %{
      "id" => _,
      "account" => %{
        "id" => _
      }
    },
    "sender" => %{
      "id" => _
    }
  }), do: true
  def valid?(_), do: false
end
