defmodule CodeCorps.BackgroundProcessingCase do
  @moduledoc """
  For use in tests which deal with parts of code that do background processing.

  Use the `wait_for_supervisor/0` helper to wait for all background tasks to
  wrap up.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      def wait_for_supervisor(), do: wait_for_children(:background_processor)

      # used to have the test wait for or the children of a supervisor to exit

      defp wait_for_children(supervisor_ref) do
        supervisor_ref
        |> Task.Supervisor.children()
        |> Enum.each(&wait_for_child/1)
      end

      defp wait_for_child(pid) do
        # Wait until the pid is dead
        ref = Process.monitor(pid)
        assert_receive {:DOWN, ^ref, _, _, :normal}
      end
    end
  end

  setup do
    on_exit fn ->
      Task.Supervisor.children(:background_processor)
      |> Enum.map(&terminate_child/1)
    end
  end

  defp terminate_child(child) do
    Task.Supervisor.terminate_child(:background_processor, child)
  end
end
