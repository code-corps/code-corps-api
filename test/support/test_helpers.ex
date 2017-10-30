defmodule CodeCorps.TestHelpers do
  use Phoenix.ConnTest
  import ExUnit.Assertions

  def ids_from_response(response) do
    Enum.map response["data"], fn(attributes) ->
      String.to_integer(attributes["id"])
    end
  end

  def assert_id_from_response(response, id) do
    assert String.to_integer(response["data"]["id"]) == id
    response
  end

  def assert_ids_from_response(response, ids) do
    assert response |> ids_from_response() |> Enum.sort() == ids |> Enum.sort()
    response
  end

  def assert_attributes(response, expected) do
    assert response["attributes"] == expected
    response
  end

  def assert_jsonapi_relationship(json = %{"relationships" => relationships}, relationship_name, id) do
    assert relationships[relationship_name]["data"]["id"] == Integer.to_string(id)
    json
  end

  def assert_jsonapi_relationship(json, relationship_name, id) do
    assert json["data"]["relationships"][relationship_name]["data"]["id"] == Integer.to_string(id)
    json
  end

  def put_id(payload, id), do: put_in(payload, ["data", "id"], id)
  def put_attributes(payload, attributes), do: put_in(payload, ["data", "attributes"], attributes)
  def put_relationships(payload, record_1, record_2), do: put_relationships(payload, [record_1, record_2])

  def put_relationships(payload, records) do
    relationships = build_relationships(%{}, records)
    payload |> put_in(["data", "relationships"], relationships)
  end

  defp build_relationships(relationship_map, []), do: relationship_map
  defp build_relationships(relationship_map, [head | tail]) do
    relationship_map
    |> Map.put(get_record_name(head), %{data: %{id: head.id}})
    |> build_relationships(tail)
  end
  defp build_relationships(relationship_map, single_param) do
    build_relationships(relationship_map, [single_param])
  end

  defp get_record_name(record) do
    record.__struct__
    |> Module.split
    |> List.last
    |> Macro.underscore
    |> String.to_existing_atom
  end
end
