defmodule CodeCorps.GitHub.API.Pagination do
  @moduledoc ~S"""
  Used to parse and build pagination data when fetching multiple pages from the GitHub API
  """

  @doc ~S"""
  Parses a collection of response headers and determines the record page count for a GitHub endpoint.

  The response the headers are retrieved from is usually generated using a
  `:head` request.

  The value of a "Link" header is used to determine the page count.

  If the "Link" header is not present in the collection, the count is assumed 1

  If the "Link" header is present, we use regex to parse the pagination info
  from its value.

  The format of the header is as follows:

  ```
  {"Link", '<https://api.github.com/search/code?q=addClass+user%3Amozilla&page=15>; rel="next",
            <https://api.github.com/search/code?q=addClass+user%3Amozilla&page=34>; rel="last",
            <https://api.github.com/search/code?q=addClass+user%3Amozilla&page=1>; rel="first",
            <https://api.github.com/search/code?q=addClass+user%3Amozilla&page=13>; rel="prev"'
  ```

  The page count is determind by locating the `rel="last"` url and extracting
  the `page` query parameter from it.
  """
  @spec retrieve_total_pages(list) :: integer
  def retrieve_total_pages(headers) do
    headers
    |> List.keyfind("Link", 0, nil)
    |> extract_total_pages
  end

  @spec extract_total_pages(nil | String.t) :: integer
  defp extract_total_pages(nil), do: 1
  defp extract_total_pages({"Link", value} = _header) do
    value
    |> String.split(", ")
    |> Enum.map(fn link ->
      rel = get_rel(link)
      page = get_page(link)
      {rel, page}
    end)
    |> Enum.into(%{})
    |> Map.get("last")
  end

  @spec get_rel(String.t) :: String.t
  defp get_rel(link) when is_binary(link) do
    # Searches for `rel=`
    Regex.run(~r{rel="([a-z]+)"}, link) |> List.last()
  end

  @spec get_page(String.t) :: integer
  defp get_page(link) when is_binary(link) do
    # Searches for the following variations:
    # ```
    # ?page={match}>
    # ?page={match}&...
    # &page={match}>
    # &page={match}&...
    # ```
    Regex.run(~r{[&/?]page=([^>&]+)}, link) |> List.last |> String.to_integer
  end

  @doc ~S"""
  From the specified page count, generates a list of integers, `1..count`
  """
  @spec to_page_numbers(integer) :: list(integer)
  def to_page_numbers(total) when is_integer(total), do: 1..total

  @doc ~S"""
  Adds a `page` query parameter to an `options` `Keyword` list.

  For `HTTPPoison`, query parameters go under the `params` key of the `options`
  argument, so this function also ensures the `params` key is present.
  """
  @spec add_page_param(Keyword.t, integer) :: Keyword.t
  def add_page_param(options, page) when is_list(options) when is_integer(page) do
    params =
      options
      |> Keyword.get(:params, [])
      |> Keyword.put(:page, page)

    options
    |> Keyword.put(:params, params)
  end
end
