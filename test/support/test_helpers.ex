defmodule CodeCorps.TestHelpers do
  use Phoenix.ConnTest
  import ExUnit.Assertions

  def ids_from_response(response) do
    Enum.map response["data"], fn(attributes) ->
      String.to_integer(attributes["id"])
    end
  end

  def assert_jsonapi_relationship(json = %{"relationships" => relationships}, relationship_name, id) do
    assert relationships[relationship_name]["data"]["id"] == Integer.to_string(id)
    json
  end

  def assert_jsonapi_relationship(json, relationship_name, id) do
    assert json["data"]["relationships"][relationship_name]["data"]["id"] == Integer.to_string(id)
    json
  end

  def assert_result_id(result, id) do
    assert String.to_integer(result["id"]) == id
    result
  end
end
