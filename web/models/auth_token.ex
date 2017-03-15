defmodule CodeCorps.AuthToken do
  @moduledoc """
  Represent's one of the user's many possible authentication tokens, created
  using `Phoenix.Token.sign/4`.

  Many can coexist and be valid at the same time. They can be used for password
  resets or passwordless logins.

  These tokens expire.
  """

  use CodeCorps.Web, :model

  schema "auth_token" do
    field :value, :string

    belongs_to :user, CodeCorps.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct`
  """
  def changeset(struct, user) do
    token = CodeCorps.Endpoint |> Phoenix.Token.sign("user", user.id)
    struct
    |> cast(%{ value: token, user_id: user.id }, [:value, :user_id])
    |> validate_required([:value, :user_id])
    |> assoc_constraint(:user)
  end
end
