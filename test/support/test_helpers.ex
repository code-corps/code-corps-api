defmodule CodeCorps.TestHelpers do
  use Phoenix.ConnTest

  def ids_from_response(response) do
    Enum.map response["data"], fn(attributes) ->
      String.to_integer(attributes["id"])
    end
  end
end
