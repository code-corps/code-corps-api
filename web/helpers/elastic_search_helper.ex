defmodule CodeCorps.ElasticSearchHelper do
  alias Elastix.Search
  alias Elastix.Index
  alias Elastix.Document

  def delete(url, index) do
    Index.delete(url, index)
  end

  def create_index(url, index, type) do
    Index.settings(url, index, settings_map())
    Index.settings(url, "#{index}/_mapping/#{type}", field_filter(type))
  end

  def add_documents(url, index, type, documents) when is_list(documents) do
    add_documents(url, index, type, documents, [])
  end

  def add_documents(url, index, type, documents, query) when is_list(documents) do
    Enum.each(documents, fn(x) -> add_document(url, index, type, x, query) end)
  end

  def add_document(url, index, type, data) do
    add_document(url, index, type, data, [])
  end

  def add_document(url, index, type, data, query) do
    Document.index_new(url, index, type, data, query)
  end

  def search(url, index, type, search_query) do
    data = %{
      query: %{
        match: %{"#{type}": search_query}
      }
    }
    Search.search(url, index, [], data) |> process_response(type)
  end

  def match_all(url, index, type) do
    data = %{
      query: %{
        match_all: %{}
      }
    }
    Search.search(url, index, [], data) |> process_response(type)
  end

  def process_response(%HTTPoison.Response{status_code: 200} = response, type) do
    response.body["hits"]["hits"] |> Enum.map(fn(x) -> x["_source"] end)
  end

  def process_response(_), do: []

  defp settings_map do
    %{
        settings: %{
          number_of_shards: 5,
          analysis: %{
            filter: %{
              autocomplete_filter: %{
                type:     "edge_ngram",
                min_gram: 2,
                max_gram: 20
              }
            },
            analyzer: %{
              autocomplete: %{
                type:      "custom",
                tokenizer: "standard",
                filter: [
                  "lowercase",
                  "autocomplete_filter"
                ]
              }
            }
          }
        }
      }
  end

  def field_filter(type) do
    %{
      "#{type}" => %{
        "properties" => %{
          "#{type}" => %{
            "type" =>     "string",
            "analyzer" =>  "autocomplete"
          }
        }
      }
    }
  end
end
