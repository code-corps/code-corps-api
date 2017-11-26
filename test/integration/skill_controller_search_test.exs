defmodule SkillControllerSearchIntegrationTest do
  use ExUnit.Case, async: true
  alias CodeCorps.ElasticSearchHelper

  @test_url Application.get_env(:code_corps, :elasticsearch_url)
  @test_index  "skills"
  @type_value "title"

  @elixir %{"id" => 1, "description" => "Elixir is an awesome functional language", "title" =>  "Elixir", "original_row" => 1}
  @ruby %{"id" => 2, "description" => "Ruby is an awesome OO language", "title" => "Ruby", "original_row" => 2}
  @rails %{"id" => 3, "description" => "Rails is a modern framework", "title" => "Rails", "original_row" => 3}
  @css %{"id" => 4, "description" => "CSS is pretty cool too", "title" => "CSS", "original_row" => 4}
  @phoenix %{"id" => 5, "description" => "Phoenix is a super framework", "title" => "Phoenix", "original_row" => 5}

  setup do
    ElasticSearchHelper.delete(@test_url, @test_index)
    ElasticSearchHelper.create_index(@test_url, @test_index, @type_value)
    init()
    :ok
  end

  test "search partial word" do
   results = ElasticSearchHelper.search(@test_url, @test_index, "title", "ru")
   assert results == [@ruby]
  end

  test "fuzzy search partial word" do
    results = ElasticSearchHelper.search(@test_url, @test_index, "title", "rj")
    # Two lists can be concatenated or subtracted using the ++/2 and --/2
    # see: http://elixir-lang.org/getting-started/basic-types.html#linked-lists
    # This allows us to confirm the values we want regardless of the order the values are returned in.
    assert results -- ["Ruby", "Rails"] == []
  end

  test "search whole word" do
    results = ElasticSearchHelper.search(@test_url, @test_index, "title", "css")
    assert results == [@css]
  end

  test "fuzzy search whole word" do
    results = ElasticSearchHelper.search(@test_url, @test_index, "title", "csw")
    assert results == [@css]
  end

  test "search no matches" do
    results = ElasticSearchHelper.search(@test_url, @test_index, "title", "foo")
    assert results == []
  end

  test "match all entries" do
    results = ElasticSearchHelper.match_all(@test_url, @test_index, "title")
    assert results -- [@elixir, @ruby, @rails, @css] == []
  end

  def init do
    ElasticSearchHelper.add_documents(@test_url, @test_index, @type_value,
      [@elixir, @css, @ruby], [refresh: true])
  end
end
