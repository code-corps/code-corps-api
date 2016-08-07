defmodule CodeCorps.UserTest do
  use CodeCorps.ModelCase

  alias CodeCorps.User

  @valid_attrs %{email: "some content", password: "some content", username: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset does not accept long usernames" do
    attrs = Map.put(@valid_attrs, :username, String.duplicate("a", 40))
    assert {:username, "should be at most 39 character(s)"} in errors_on(%User{}, attrs)
  end

  test "registration_changeset password must be at least 6 chars long" do
    attrs = Map.put(@valid_attrs, :password, "12345")
    changeset = User.registration_changeset(%User{}, attrs)
    assert {:password, {"should be at least %{count} character(s)", count: 6}} in changeset.errors
  end

  test "registration_changeset with valid attributes hashes password" do
    attrs = Map.put(@valid_attrs, :password, "123456")
    changeset = User.registration_changeset(%User{}, attrs)
    %{password: pass, encrypted_password: encrypted_password} = changeset.changes
    assert changeset.valid?
    assert encrypted_password
    assert Comeonin.Bcrypt.checkpw(pass, encrypted_password)
  end

  describe "update_changeset" do
    test "requires :twitter to be in proper format" do
      user = %User{}
      attrs = %{twitter: "bad @ twitter"}

      changeset = User.update_changeset(user, attrs)

      assert changeset.errors[:twitter] == {"has invalid format", []}
    end

    test "doesn't require :twitter to be part of the changes" do
      user = %User{}
      attrs = %{}

      changeset = User.update_changeset(user, attrs)

      refute Keyword.has_key?(changeset.errors, :twitter)
    end

    test "requires :website to be in proper format" do
      user = %User{}
      attrs = %{website: "bad <> website"}

      changeset = User.update_changeset(user, attrs)

      assert changeset.errors[:website] == {"has invalid format", []}
    end

    test "doesn't require :website to be part of the changes" do
      user = %User{}
      attrs = %{}

      changeset = User.update_changeset(user, attrs)

      refute Keyword.has_key?(changeset.errors, :website)
    end

    test "prefixes website with 'http://' if there is no prefix" do
      user = %User{website: "https://first.com"}
      attrs = %{website: "example.com"}

      changeset = User.update_changeset(user, attrs)

      assert changeset.changes.website == "http://example.com"
    end

    test "doesn't make a change to the url when there is no param for it" do
      user = %User{website: "https://first.com"}
      attrs = %{}

      changeset = User.update_changeset(user, attrs)

      refute Map.has_key?(changeset.changes, :website)
    end
  end
end
