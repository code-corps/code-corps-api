defmodule CodeCorps.GitHub.TestHelpers do
  @spec load_endpoint_fixture(String.t) :: map
  def load_endpoint_fixture(id) do
    "./test/fixtures/github/endpoints/#{id}.json" |> File.read! |> Poison.decode!
  end

  @spec load_event_fixture(String.t) :: map
  def load_event_fixture(id) do
    "./test/fixtures/github/events/#{id}.json" |> File.read! |> Poison.decode!
  end

  @doc ~S"""
  Allows setting a mock Github API module for usage in specific tests
  To use it, define a module containing the methods expected to be called, then
  pass in the block of code expected to call it into the macro:
  ```
  defmodule MyApiModule do
    def some_function, do: "foo"
  end
  with_mock_api(MyApiModule) do
    execute_code_calling_api
  end
  ```
  """
  @spec with_mock_api(module, do: function) :: any
  defmacro with_mock_api(mock_module, do: block) do
    quote do
      old_mock = Application.get_env(:code_corps, :github)
      Application.put_env(:code_corps, :github, unquote(mock_module))

      unquote(block)

      Application.put_env(:code_corps, :github, old_mock)
    end
  end
end
