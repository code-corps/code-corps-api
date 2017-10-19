defmodule CodeCorps.GitHub.Sync.PullRequest.BodyParser do
  @moduledoc ~S"""
  In charge of extracting ids from markdown content, paired to a predefined list
  of keywords.
  """

  @doc ~S"""
  Searchs for GitHub closing keyword format inside a content string. Returns all
  unique ids matched, as integers.
  """
  @spec extract_closing_ids(String.t) :: list(integer)
  def extract_closing_ids(content) when is_binary(content) do
    ~w(close closes closed fix fixes fixed resolve resolves resolved)
    |> matching_regex()
    |> Regex.scan(content) # [["closes #1", "closes", "1"], ["fixes #2", "fixes", "2"]]
    |> Enum.map(&List.last/1) # ["1", "2"]
    |> Enum.map(&String.to_integer/1) # [1, 2]
    |> Enum.uniq
  end

  defp matching_regex(keywords) do
    matches = keywords |> Enum.join("|")
    ~r/(?:(#{matches}))\s+#(\d+)/i
  end
end
