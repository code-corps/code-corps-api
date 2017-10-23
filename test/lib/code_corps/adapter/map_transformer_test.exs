defmodule CodeCorps.Adapter.MapTransformerTest do
  use ExUnit.Case

  alias CodeCorps.Adapter.MapTransformer

  @mapping [{:id, ["id"]}, {:user_id, ["user", "id"]}]

  describe "transform/2" do
    test "transforms map correctly" do
      map = %{"id" => 1, "user" => %{"id" => 1}}

      assert MapTransformer.transform(map, @mapping) == %{id: 1, user_id: 1}
    end
  end

  describe "transform_inverse/2" do
    test "inverse transforms map correctly" do
      map = %{id: 1, user_id: 1}

      assert MapTransformer.transform_inverse(map, @mapping) == %{"id" => 1, "user" => %{"id" => 1}}
    end
  end
end
