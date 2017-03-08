defmodule CodeCorps.UserTest do
  use CodeCorps.ModelCase

  alias CodeCorps.User

  @valid_attrs %{email: "test@user.com", password: "somepassword", username: "testuser"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with invalid email" do
    attrs = Map.put(@valid_attrs, :email, "notanemail")
    changeset = User.changeset(%User{}, attrs)
    assert_error_message(changeset, :email, "has invalid format")
  end

  describe "registration_changeset" do
    test "does not accept long usernames" do
      attrs = Map.put(@valid_attrs, :username, String.duplicate("a", 40))
      changeset = User.registration_changeset(%User{}, attrs)
      assert {:username, {"should be at most %{count} character(s)", [count: 39, validation: :length, max: 39]}} in changeset.errors
    end

    test "password must be at least 6 chars long" do
      attrs = Map.put(@valid_attrs, :password, "12345")
      changeset = User.registration_changeset(%User{}, attrs)
      assert {:password, {"should be at least %{count} character(s)", [count: 6, validation: :length, min: 6]}} in changeset.errors
    end

    test "with valid attributes hashes password" do
      attrs = Map.put(@valid_attrs, :password, "123456")
      changeset = User.registration_changeset(%User{}, attrs)
      %{password: pass, encrypted_password: encrypted_password} = changeset.changes
      assert changeset.valid?
      assert encrypted_password
      assert Comeonin.Bcrypt.checkpw(pass, encrypted_password)
    end

    test "does not allow duplicate emails" do
      user_1_attrs = %{email: "duplicate@email.com", password: "password", username: "user_1"}
      user_2_attrs = %{email: "duplicate@email.com", password: "password", username: "user_2"}
      insert(:user, user_1_attrs)
      changeset = User.registration_changeset(%User{}, user_2_attrs)
      {:error, changeset} = Repo.insert(changeset)
      refute changeset.valid?
      assert_error_message(changeset, :email, "has already been taken")
    end

    test "does not allow duplicate usernames, regardless of case" do
      user_1_attrs = %{email: "user_1@email.com", password: "password", username: "duplicate"}
      user_2_attrs = %{email: "user_2@email.com", password: "password", username: "DUPLICATE"}
      insert(:user, user_1_attrs)
      changeset = User.registration_changeset(%User{}, user_2_attrs)
      {:error, changeset} = Repo.insert(changeset)
      refute changeset.valid?
      assert_error_message(changeset, :username, "has already been taken")
    end
  end

  describe "update_changeset" do
    test "requires :twitter to be in proper format" do
      user = %User{}
      attrs = %{twitter: "bad @ twitter"}

      changeset = User.update_changeset(user, attrs)

      assert_error_message(changeset, :twitter, "has invalid format")
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

      assert_error_message(changeset, :website, "has invalid format")
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

    test "prevents an invalid transition" do
      user = insert(:user, state: "signed_up")

      changeset = user |> User.update_changeset(%{state_transition: "yehaww"})

      refute changeset.valid?
      [error | _] = changeset.errors
      {attribute, {message, _}} = error
      assert attribute == :state_transition
      assert message == "invalid transition yehaww from signed_up"
    end
  end

  test "reset_password_changeset with valid passwords" do
    changeset = User.reset_password_changeset(%User{}, %{password: "foobar", password_confirmation: "foobar"})
    assert changeset.valid?
    assert changeset.changes.encrypted_password
  end

  test "reset_password_changeset with invalid passwords generates message" do
    changeset = User.reset_password_changeset(%User{}, %{password: "wat", password_confirmation: "foobar"})
    refute changeset.valid?
    [error | _] = changeset.errors
    {attribute, {message, _}} = error
    assert attribute == :password_confirmation
    assert message == "passwords do not match"
  end
end
