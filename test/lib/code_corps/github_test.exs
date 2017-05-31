defmodule CodeCorps.GithubTest do
  use CodeCorps.ModelCase
  alias CodeCorps.Github

  describe "associate/2" do
    test "should update the user with the github_id" do
      user = insert(:user)
      params = %{github_id: "foobar"}
      {:ok, result} = Github.associate(user, params)
      assert result.github_id == "foobar"
    end

    test "should return the error with a changeset" do
      user = insert(:user)
      params = %{}
      {:error, changeset} = Github.associate(user, params)
      refute changeset.valid?
    end
  end
end
