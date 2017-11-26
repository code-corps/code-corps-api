defmodule CodeCorps.AccountsTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  alias CodeCorps.Skills

  describe "popular/1" do
    test "returns popular skills in order with a limit" do
      [least_popular, somewhat_popular, most_popular] = insert_list(3, :skill)
      insert_list(3, :user_skill, skill: most_popular)
      insert_list(2, :user_skill, skill: somewhat_popular)
      insert_list(1, :user_skill, skill: least_popular)

      [first_result, last_result] = Skills.popular(%{"limit" => "2"})

      assert first_result == most_popular
      assert last_result == somewhat_popular
    end

    test "defaults limit to 10" do
      skills = insert_list(11, :skill)
      skills |> Enum.each(fn skill -> insert(:user_skill, skill: skill) end)

      results = Skills.popular()

      assert results |> Enum.count() == 10
    end

    test "ignores non-number limits" do
      insert(:user_skill)

      results = Skills.popular(%{"limit" => "apples"})

      assert results |> Enum.count() == 1
    end
  end
end
