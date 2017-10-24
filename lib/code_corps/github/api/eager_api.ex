defmodule CodeCorps.GitHub.EagerAPI do
  @moduledoc """
  Eager loads a resource from the GitHub API by fetching all of its pages in
  parallel.
  """

  def get_all(url, headers, options) do
    HTTPoison.start
    {:ok, response} = HTTPoison.get(url, headers, options)

    first_page = Poison.decode!(response.body)
    case response.headers |> retrieve_total_pages do
      1 -> first_page
      total ->
        first_page ++ get_remaining_pages(total, url, headers, options) |> List.flatten
    end
  end

  defp get_remaining_pages(total, url, headers, options) do
    2..total
    |> Enum.to_list
    |> Enum.map(&Task.async(fn ->
      params = options[:params] ++ [page: &1]
      HTTPoison.get(url, headers, options ++ [params: params])
    end))
    |> Enum.map(&Task.await(&1, 10000))
    |> Enum.map(&handle_page_response/1)
  end

  defp handle_page_response({:ok, %{body: body}}), do: Poison.decode!(body)

  def retrieve_total_pages(headers) do
    case headers |> List.keyfind("Link", 0, nil) do
      nil -> 1
      {"Link", value} -> value |> extract_total_pages
    end
  end

  defp extract_total_pages(links_string) do
    # We use regex to parse the pagination info from the GitHub API response
    # headers.
    #
    # The headers render pages in the following format:
    #
    # ```
    # {"Link", '<https://api.github.com/search/code?q=addClass+user%3Amozilla&page=15>; rel="next",
    #           <https://api.github.com/search/code?q=addClass+user%3Amozilla&page=34>; rel="last",
    #           <https://api.github.com/search/code?q=addClass+user%3Amozilla&page=1>; rel="first",
    #           <https://api.github.com/search/code?q=addClass+user%3Amozilla&page=13>; rel="prev"'
    # ```
    #
    # If the response has no list header, then we have received all the records
    # from the only possible page.
    #
    # If the response has a list header, the value will contain at least the
    # "last" relation.
    links_string
    |> String.split(", ")
    |> Enum.map(fn link ->
      rel = get_rel(link)
      page = get_page(link)
      {rel, page}
    end)
    |> Enum.into(%{})
    |> Map.get("last")
  end

  defp get_rel(link) do
    # Searches for `rel=`
    Regex.run(~r{rel="([a-z]+)"}, link) |> List.last()
  end

  defp get_page(link) do
    # Searches for the following variations:
    # ```
    # ?page={match}>
    # ?page={match}&...
    # &page={match}>
    # &page={match}&...
    # ```
    Regex.run(~r{[&/?]page=([^>&]+)}, link) |> List.last |> String.to_integer
  end
end
