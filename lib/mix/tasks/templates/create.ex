defmodule Mix.Tasks.Templates.Create do
  @moduledoc """
  Initializes blank templates on SparkPost.
  Should only need to be caled once per environment
  """
  use Mix.Task

  require Logger

  def run(_) do
    CodeCorps.SparkPost.create_templates()
    |> Enum.each(&log_result(&1))
  end

  defp log_result({id, {:ok, _result}}), do: Logger.log(:info, "Template #{id} created sucessfuly.")
  defp log_result({id, {:error, error}}) do
    Logger.log(:error, "Failed to create template #{id}. The response was:")
    Logger.log(:warn, Kernel.inspect(error, pretty: true))
  end
end
