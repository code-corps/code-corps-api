defmodule CodeCorps.GitHub.Utils.ResultAggregatorTest do
  use CodeCorps.DbAccessCase

  alias CodeCorps.{
    Comment,
    GitHub.Utils.ResultAggregator,
    GithubRepo,
    Task,
  }
  alias Ecto.Changeset

  describe "aggregate/1" do
    test "aggregates Task results correctly" do
      record = %Task{}
      good = {:ok, record}
      changeset = %Changeset{}
      bad = {:error, changeset}

      assert [] |> ResultAggregator.aggregate == {:ok, []}
      assert [good] |> ResultAggregator.aggregate == {:ok, [record]}
      assert [good, good] |> ResultAggregator.aggregate == {:ok, [record, record]}
      assert [good, bad] |> ResultAggregator.aggregate == {:error, {[record], [changeset]}}
      assert [bad] |> ResultAggregator.aggregate == {:error, {[], [changeset]}}
      assert [bad, bad] |> ResultAggregator.aggregate == {:error, {[], [changeset, changeset]}}
    end

    test "aggregates Comment results correctly" do
      record = %Comment{}
      good = {:ok, record}
      changeset = %Changeset{}
      bad = {:error, changeset}

      assert [] |> ResultAggregator.aggregate == {:ok, []}
      assert [good] |> ResultAggregator.aggregate == {:ok, [record]}
      assert [good, good] |> ResultAggregator.aggregate == {:ok, [record, record]}
      assert [good, bad] |> ResultAggregator.aggregate == {:error, {[record], [changeset]}}
      assert [bad] |> ResultAggregator.aggregate == {:error, {[], [changeset]}}
      assert [bad, bad] |> ResultAggregator.aggregate == {:error, {[], [changeset, changeset]}}
    end

    test "aggregates GithubRepo results correctly" do
      record = %GithubRepo{}
      good = {:ok, record}
      changeset = %Changeset{}
      bad = {:error, changeset}

      assert [] |> ResultAggregator.aggregate == {:ok, []}
      assert [good] |> ResultAggregator.aggregate == {:ok, [record]}
      assert [good, good] |> ResultAggregator.aggregate == {:ok, [record, record]}
      assert [good, bad] |> ResultAggregator.aggregate == {:error, {[record], [changeset]}}
      assert [bad] |> ResultAggregator.aggregate == {:error, {[], [changeset]}}
      assert [bad, bad] |> ResultAggregator.aggregate == {:error, {[], [changeset, changeset]}}
    end
  end
end
