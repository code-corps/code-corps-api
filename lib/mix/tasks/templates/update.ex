defmodule Mix.Tasks.Templates.Update do
  @moduledoc """
  Updates SparkPost templates with template data created locally.
  Should only be called whenever a template needs to be changed.
  """
  use Mix.Task

  require Logger

  def run(_) do
    CodeCorps.SparkPost.update_templates()
    |> Enum.each(&log_result(&1))
  end

  defp log_result({id, {:ok, _result}}), do: Logger.log(:info, "Template #{id} updated sucessfuly.")
  defp log_result({id, {:error, error}}) do
    Logger.log(:error, "Failed to update template #{id}. The response was:")
    Logger.log(:warn, Kernel.inspect(error, pretty: true))
  end
end
