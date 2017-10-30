defmodule CodeCorps.Accounts.Changesets do
  @moduledoc ~S"""
  Changesets for Code Corps accounts.
  """

  import CodeCorpsWeb.Gettext

  alias CodeCorps.GitHub.Adapters
  alias CodeCorps.Helpers.RandomIconColor
  alias Ecto.Changeset

  @doc ~S"""
  Casts a changeset used for creating a user account from a GitHub user payload
  """
  @spec create_from_github_changeset(struct, map) :: Changeset.t
  def create_from_github_changeset(struct, %{} = params) do
    struct
    |> Changeset.change(params |> Adapters.User.to_user())
    |> Changeset.put_change(:sign_up_context, "github")
    |> Changeset.validate_inclusion(:type, ["bot", "user"])
    |> RandomIconColor.generate_icon_color(:default_color)
    |> Changeset.unique_constraint(:email)
    |> Changeset.assoc_constraint(:github_user)
    |> unique_github_constraint()
  end

  @doc ~S"""
  Casts a changeset used for updating a user account from a GitHub user payload
  """
  @spec update_with_github_user_changeset(struct, map) :: Changeset.t
  def update_with_github_user_changeset(struct, %{} = params) do
    struct
    |> Changeset.cast(params, [:github_avatar_url, :github_id, :github_username, :type])
    |> ensure_email_without_overwriting(params)
    |> Changeset.validate_required([:github_avatar_url, :github_id, :github_username, :type])
    |> Changeset.unique_constraint(:email)
    |> unique_github_constraint()
  end

  @doc ~S"""
  Casts a changeset used for updating a user account from a GitHub OAuth payload
  """
  @spec update_from_github_oauth_changeset(struct, map) :: Changeset.t
  def update_from_github_oauth_changeset(struct, %{} = params) do
    struct
    |> Changeset.cast(params, [:github_auth_token, :github_avatar_url, :github_id, :github_username, :type])
    |> ensure_email_without_overwriting(params)
    |> Changeset.validate_required([:github_auth_token, :github_avatar_url, :github_id, :github_username, :type])
    |> Changeset.unique_constraint(:email)
    |> unique_github_constraint()
  end

  @spec ensure_email_without_overwriting(Changeset.t, map) :: Changeset.t
  defp ensure_email_without_overwriting(%Changeset{} = changeset, %{"email" => new_email} = _params) do
    case changeset |> Changeset.get_field(:email) do
      nil -> changeset |> Changeset.put_change(:email, new_email)
      _email -> changeset
    end
  end
  defp ensure_email_without_overwriting(%Changeset{} = changeset, _params), do: changeset

  defp unique_github_constraint(struct) do
    struct
    |> Changeset.unique_constraint(:github_id, message: dgettext("errors", "account is already connected to someone else"))
  end
end
