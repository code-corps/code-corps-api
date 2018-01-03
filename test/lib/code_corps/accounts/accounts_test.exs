defmodule CodeCorps.AccountsTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  alias CodeCorps.{
    Accounts,
    Comment,
    ProjectUser,
    Task,
    GitHub.TestHelpers,
    User,
    UserInvite
  }

  alias Ecto.Changeset

  describe "create/1" do
    @valid_user_params %{
      "email" => "test@user.com",
      "password" => "somepassword",
      "username" => "testuser"
    }

    test "creates user" do
      {:ok, %User{} = user} =
        @valid_user_params
        |> Accounts.create()

      assert Repo.get(User, user.id)
    end

    test "returns changeset if validation errors" do
      {:error, %Changeset{} = changeset} =
        @valid_user_params
        |> Map.delete("email")
        |> Accounts.create()

      refute changeset.valid?
    end

    test "claims invite if id providedf" do
      invite = insert(:user_invite, invitee: nil, project: nil)

      {:ok, %User{} = user} =
        @valid_user_params
        |> Map.put("invite_id", invite.id)
        |> Accounts.create()

      assert Repo.get(User, user.id)
    end

    test "tracks invite claim with segment" do
      invite = insert(:user_invite, invitee: nil, project: nil)

      {:ok, %User{} = user} =
        @valid_user_params
        |> Map.put("invite_id", invite.id)
        |> Accounts.create()

      %{id: created_user_id} = Repo.get(User, user.id)

      traits =
        UserInvite |> Repo.get(invite.id) |> CodeCorps.Analytics.SegmentTraitsBuilder.build()

      assert_received({:track, ^created_user_id, "Claimed User Invite", ^traits})
    end

    test "associates invite with user" do
      invite = insert(:user_invite, invitee: nil, project: nil)

      {:ok, %User{} = user} =
        @valid_user_params
        |> Map.put("invite_id", invite.id)
        |> Accounts.create()

      assert Repo.one(UserInvite).invitee_id == user.id
    end

    test "creates project membership if project provided with invite" do
      project = insert(:project)
      invite = insert(:user_invite, invitee: nil, project: project, role: "admin")

      {:ok, %User{} = user} =
        @valid_user_params
        |> Map.put("invite_id", invite.id)
        |> Accounts.create()

      assert Repo.get_by(ProjectUser, user_id: user.id, project_id: project.id, role: "admin")
    end

    test "returns :invite_not_found if bad invite id provided" do
      response =
        @valid_user_params
        |> Map.put("invite_id", -1)
        |> Accounts.create()

      assert response == {:error, :invite_not_found}
    end
  end

  describe "create_from_github/1" do
    test "creates proper user from provided payload" do
      {:ok, %User{} = user} =
        "user"
        |> TestHelpers.load_endpoint_fixture()
        |> Accounts.create_from_github()

      assert user.id
      assert user.default_color
      assert user.sign_up_context == "github"
      assert user.type == "user"
    end

    test "validates the uniqueness of email" do
      %{"email" => email} = payload = TestHelpers.load_endpoint_fixture("user")

      # Ensure a user exists so there's a duplicate email
      insert(:user, email: email)

      {:error, %Changeset{} = changeset} =
        payload
        |> Accounts.create_from_github()

      assert changeset.errors[:email] == {"has already been taken", []}
    end

    test "validates the uniqueness of the github_id" do
      %{"id" => github_id} = payload = TestHelpers.load_endpoint_fixture("user")

      # Ensure a user exists so there's a duplicate github_id
      insert(:user, github_id: github_id)

      {:error, %Changeset{} = changeset} =
        payload
        |> Accounts.create_from_github()

      assert changeset.errors[:github_id] == {"account is already connected to someone else", []}
    end

    test "uploads photo from GitHub avatar" do
      {:ok, %User{} = user} =
        "user"
        |> TestHelpers.load_endpoint_fixture()
        |> Accounts.create_from_github()

      user = Repo.get(User, user.id)
      assert user.cloudinary_public_id
    end
  end

  describe "update_from_github_oauth/3" do
    test "updates proper user and associations given GitHub payload" do
      user = insert(:user)
      %{"id" => github_id} = params = TestHelpers.load_endpoint_fixture("user")
      token = "random_token"

      {:ok, %User{} = user_for_github_user} =
        params
        |> Accounts.create_from_github()

      comment = insert(:comment, user: user_for_github_user)
      task = insert(:task, user: user_for_github_user)

      {:ok, %User{} = user} =
        user
        |> Accounts.update_from_github_oauth(params, token)

      user_for_github_user = Repo.get(User, user_for_github_user.id)
      comment = Repo.get(Comment, comment.id)
      task = Repo.get(Task, task.id)

      # Unsets the old user's github_id
      assert user_for_github_user.sign_up_context == "github"
      assert user_for_github_user.github_id_was == github_id
      refute user_for_github_user.github_id

      # Sets the new user data
      assert user.id
      assert user.github_auth_token == token
      assert user.github_id == github_id
      assert user.sign_up_context == "default"
      assert user.type == "user"

      # Changes associations
      assert comment.user_id == user.id
      assert task.user_id == user.id
    end

    test "does not update their image if it already exists" do
      user = insert(:user, cloudinary_public_id: "123")
      params = TestHelpers.load_endpoint_fixture("user")

      {:ok, %User{} = user} =
        user
        |> Accounts.update_from_github_oauth(params, "random_token")

      user = Repo.get(User, user.id)

      assert user.cloudinary_public_id === "123"
    end

    test "updates their image if does not exist" do
      user = insert(:user, cloudinary_public_id: nil)
      params = TestHelpers.load_endpoint_fixture("user")

      {:ok, %User{} = user} =
        user
        |> Accounts.update_from_github_oauth(params, "random_token")

      user = Repo.get(User, user.id)

      assert user.cloudinary_public_id
    end
  end

  describe "create_invite/1" do
    @base_attrs %{email: "foo@example.com"}

    test "creates a user invite" do
      %{id: inviter_id} = insert(:user)

      {:ok, %UserInvite{} = user_invite} =
        @base_attrs
        |> Map.put(:inviter_id, inviter_id)
        |> Accounts.create_invite()

      assert Repo.one(UserInvite).id == user_invite.id
    end

    test "requires email" do
      {:error, changeset} =
        @base_attrs
        |> Map.delete(:email)
        |> Accounts.create_invite()

      refute changeset.valid?
      assert changeset.errors[:email]
    end

    test "requires valid inviter id" do
      {:error, changeset} =
        @base_attrs
        |> Accounts.create_invite()

      refute changeset.valid?
      assert changeset.errors[:inviter_id]

      {:error, changeset} =
        @base_attrs
        |> Map.put(:inviter_id, -1)
        |> Accounts.create_invite()

      refute changeset.valid?
      refute changeset.errors[:inviter_id]
      assert changeset.errors[:inviter]
    end

    test "allows specifying name" do
      %{id: inviter_id} = insert(:user)

      {:ok, %UserInvite{} = user_invite} =
        @base_attrs
        |> Map.put(:inviter_id, inviter_id)
        |> Map.put(:name, "John")
        |> Accounts.create_invite()

      assert user_invite.name == "John"
    end

    test "creates a user invite for a project" do
      %{id: inviter_id} = insert(:user)
      %{id: project_id} = insert(:project)

      {:ok, %UserInvite{} = user_invite} =
        @base_attrs
        |> Map.put(:inviter_id, inviter_id)
        |> Map.put(:role, "admin")
        |> Map.put(:project_id, project_id)
        |> Accounts.create_invite()

      assert user_invite.role == "admin"
      assert user_invite.project_id == project_id
    end

    test "does not allow invalid roles" do
      %{id: inviter_id} = insert(:user)
      %{id: project_id} = insert(:project)

      {:error, changeset} =
        @base_attrs
        |> Map.put(:inviter_id, inviter_id)
        |> Map.put(:role, "foo")
        |> Map.put(:project_id, project_id)
        |> Accounts.create_invite()

      refute changeset.valid?
      assert changeset.errors[:role]
    end

    test "requires valid project id" do
      %{id: inviter_id} = insert(:user)

      {:error, changeset} =
        @base_attrs
        |> Map.put(:inviter_id, inviter_id)
        |> Map.put(:project_id, -1)
        |> Map.put(:role, "contributor")
        |> Accounts.create_invite()

      refute changeset.valid?
      assert changeset.errors[:project]
    end

    test "requires role if project is specified" do
      %{id: inviter_id} = insert(:user)
      %{id: project_id} = insert(:project)

      {:error, changeset} =
        @base_attrs
        |> Map.put(:inviter_id, inviter_id)
        |> Map.put(:project_id, project_id)
        |> Accounts.create_invite()

      refute changeset.valid?
      assert changeset.errors[:role]
    end

    test "requires project_id if role is specified" do
      %{id: inviter_id} = insert(:user)

      {:error, changeset} =
        @base_attrs
        |> Map.put(:inviter_id, inviter_id)
        |> Map.put(:role, "contributor")
        |> Accounts.create_invite()

      refute changeset.valid?
      assert changeset.errors[:project_id]
    end

    test "requires user not to be registered with email" do
      %{id: inviter_id} = insert(:user)
      %{email: email} = insert(:user)

      {:error, changeset} =
        %{email: email}
        |> Map.put(:inviter_id, inviter_id)
        |> Accounts.create_invite()

      refute changeset.valid?
      assert changeset.errors[:email]
    end
  end
end
