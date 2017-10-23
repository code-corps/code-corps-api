defmodule CodeCorps.GitHub.Sync.PullRequest.BodyParserTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias CodeCorps.{
    GitHub.Sync.PullRequest.BodyParser
  }

  describe "extract_closing_ids/1" do
    test "correctly extracts ids using supported closing keywords" do
      content =
        """
        close #2, closes #3 closed #4: fixed #5 fixes #6 fix #7.
        resolve #8 resolves #9 #resolved #10
        """

      assert content |> BodyParser.extract_closing_ids == 2..10 |> Enum.to_list
    end

    test "only returns unique results" do
      content =
        """
        close #2, closes #2 closed #3: fixed #4 fixes #5 fix #6.
        resolve #7 resolves #8 #resolved #8
        """

      assert content |> BodyParser.extract_closing_ids == 2..8 |> Enum.to_list
    end
  end
end
