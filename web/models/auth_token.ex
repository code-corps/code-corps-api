defmodule CodeCorps.AuthToken do
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
    |> cast(%{ value: token }, [:value])
    |> validate_required([:value])
  end
end
