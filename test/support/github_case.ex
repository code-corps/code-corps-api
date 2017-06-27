defmodule CodeCorps.GitHubCase do
  @moduledoc ~S"""
  For use in tests where Bypass is needed.

  The module is mainly used through tags.

  Example:

    ```
    use CodeCorps.GitHubCase

    @tag bypass: %{
      "/path/to/request" => {status_code, data_to_respond_with},
      "/path/to/other/request" => {status_code, data_to_respond_with}
      # etc...
    }
    test "some test which makes a github api request" do
      # run test code here, all github API requests will automatically respond
      # as specified, if listed in the bypass tag
    end
  """

  alias CodeCorps.GitHub

  use ExUnit.CaseTemplate

  setup tags do
    bypass = Bypass.open

    GitHub.Bypass.setup(bypass)

    case tags |> Map.get(:bypass) do
      nil -> nil
      bypass_data -> bypass |> setup_handling(bypass_data)
    end

    on_exit fn ->
      GitHub.Bypass.teardown()
    end

    {:ok, bypass: bypass}
  end

  defp setup_handling(bypass, handler_data) do
    bypass |> Bypass.expect(fn %Plug.Conn{request_path: path} = conn ->
      {status, data} = handler_data |> Map.get(path)
      response = data |> Poison.encode!
      conn |> Plug.Conn.resp(status, response)
    end)
  end
end
