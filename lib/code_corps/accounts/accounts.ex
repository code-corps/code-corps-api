defmodule CodeCorps.Accounts do
  @moduledoc ~S"""
  Main entry-point for managing accounts.

  All actions to accounts should go through here.
  """

  alias CodeCorps.{
    Accounts,
    Accounts.Changesets,
    Comment,
    GitHub.Adapters,
    GithubAppInstallation,
    GithubUser,
    Processor,
    Task,
    User,
    UserInvite,
    Repo
  }
  alias Ecto.{Changeset, Multi}

  import Ecto.Query

  @doc ~S"""
  Creates a user record using attributes from a GitHub payload.
  """
  @spec create_from_github(map) :: {:ok, User.t} | {:error, Changeset.t}
  def create_from_github(%{} = attrs) do
    with {:ok, user} <- do_create_from_github(attrs) do
      user |> upload_github_photo_async
      {:ok, user}
    else
      error -> error
    end
  end

  @spec do_create_from_github(map) :: {:ok, User.t} | {:error, Changeset.t}
  defp do_create_from_github(%{} = attrs) do
    %User{}
    |> Changesets.create_from_github_changeset(attrs)
    |> Repo.insert
  end

  @doc ~S"""
  Creates a user record using attributes from a GitHub payload.
  """
  @spec create_from_github_user(GithubUser.t) :: {:ok, User.t} | {:error, Changeset.t}
  def create_from_github_user(%GithubUser{} = github_user) do
    with {:ok, user} <- do_create_from_github_user(github_user) do
      user |> upload_github_photo_async
      {:ok, user}
    else
      error -> error
    end
  end

  @spec do_create_from_github_user(GithubUser.t) :: {:ok, User.t} | {:error, Changeset.t}
  defp do_create_from_github_user(%GithubUser{} = github_user) do
    %User{}
    |> Changesets.create_from_github_changeset(github_user |> Adapters.User.to_user_attrs())
    |> Changeset.put_assoc(:github_user, github_user)
    |> Repo.insert
  end

  @spec update_with_github_user(User.t, GithubUser.t) :: {:ok, User.t} | {:error, Changeset.t}
  def update_with_github_user(%User{} = user, %GithubUser{} = github_user) do
    with {:ok, user} <- do_update_with_github_user(user, github_user) do
      user |> upload_github_photo_async
      {:ok, user}
    else
      error -> error
    end
  end

  @spec do_update_with_github_user(User.t, GithubUser.t) :: {:ok, User.t} | {:error, Changeset.t}
  defp do_update_with_github_user(%User{} = user, %GithubUser{} = github_user) do
    user
    |> Changesets.update_with_github_user_changeset(github_user |> Adapters.User.to_user_attrs())
    |> Changeset.put_assoc(:github_user, github_user)
    |> Repo.update
  end

  @doc ~S"""
  Updates a user record using attributes from a GitHub payload along with the
  access token.
  """
  @spec update_from_github_oauth(User.t, map, String.t) :: {:ok, User.t} | {:error, Changeset.t}
  def update_from_github_oauth(%User{} = user, %{} = params, access_token) do
    params =
      params
      |> Adapters.User.to_user()
      |> Map.put(:github_auth_token, access_token)

    changeset = user |> Changesets.update_from_github_oauth_changeset(params)

    multi =
      Multi.new
      |> Multi.run(:existing_user, fn _ -> params |> update_existing_user_if_any() end)
      |> Multi.update(:user, changeset)
      |> Multi.run(:installations, fn %{user: %User{} = user} -> user |> associate_installations() end)
      |> Multi.run(:tasks, fn %{user: %User{} = user} -> user |> associate_tasks() end)
      |> Multi.run(:comments, fn %{user: %User{} = user} -> user |> associate_comments() end)

    case Repo.transaction(multi) do
      {:ok, %{user: %User{} = user, installations: installations}} ->
        user |> upload_github_photo_async
        {:ok, user |> Map.put(:github_app_installations, installations)}
      {:error, :user, %Changeset{} = changeset, _actions_done} ->
        {:error, changeset}
    end
  end

  defp update_existing_user_if_any(%{github_id: github_id}) do
    case Repo.get_by(User, github_id: github_id, sign_up_context: "github") do
      %User{} = existing_user -> existing_user |> do_update_existing_user()
      _ -> {:ok, nil}
    end
  end

  defp do_update_existing_user(%User{github_id: github_id} = user) do
    params = %{github_id: nil, github_id_was: github_id}
    user
    |> Changesets.dissociate_github_user_changeset(params)
    |> Repo.update()
  end

  @spec upload_github_photo_async(User.t) :: User.t | Processor.result
  defp upload_github_photo_async(%User{cloudinary_public_id: nil} = user) do
    Processor.process(fn -> upload_github_photo(user) end)
  end
  defp upload_github_photo_async(%User{} = user), do: user

  defp upload_github_photo(%User{github_avatar_url: github_avatar_url} = user) do
    {:ok, %Cloudex.UploadedImage{public_id: cloudinary_public_id}} =
      github_avatar_url
      |> CodeCorps.Cloudex.Uploader.upload()

    user
    |> Changeset.change(%{cloudinary_public_id: cloudinary_public_id})
    |> Repo.update!
  end

  @spec associate_installations(User.t) :: {:ok, list(GithubAppInstallation.t)}
  defp associate_installations(%User{id: user_id, github_id: github_id}) do
    updates = [set: [user_id: user_id]]
    update_options = [returning: true]

    GithubAppInstallation
    |> where([i], i.sender_github_id == ^github_id)
    |> where([i], is_nil(i.user_id))
    |> Repo.update_all(updates, update_options)
    |> (fn {_count, installations} -> {:ok, installations} end).()
  end

  @spec associate_tasks(User.t) :: {:ok, list(Task.t)}
  defp associate_tasks(%User{id: user_id, github_id: github_id}) do
    updates = [set: [user_id: user_id]]
    update_options = [returning: true]

    existing_user_ids =
      User
      |> where(github_id_was: ^github_id)
      |> select([u], u.id)
      |> Repo.all

    Task
    |> where([t], t.user_id in ^existing_user_ids)
    |> Repo.update_all(updates, update_options)
    |> (fn {_count, tasks} -> {:ok, tasks} end).()
  end

  @spec associate_comments(User.t) :: {:ok, list(Comment.t)}
  defp associate_comments(%User{id: user_id, github_id: github_id}) do
    updates = [set: [user_id: user_id]]
    update_options = [returning: true]

    existing_user_ids =
      User
      |> where(github_id_was: ^github_id)
      |> select([u], u.id)
      |> Repo.all

    Comment
    |> where([c], c.user_id in ^existing_user_ids)
    |> Repo.update_all(updates, update_options)
    |> (fn {_count, comments} -> {:ok, comments} end).()
  end

  @spec create_invite(map) :: {:ok, UserInvite.t} | {:error, Changeset.t}
  defdelegate create_invite(params), to: Accounts.UserInvites
end
