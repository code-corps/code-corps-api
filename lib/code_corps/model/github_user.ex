defmodule CodeCorps.GithubUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "github_users" do
    field :avatar_url, :string
    field :email, :string
    field :github_id, :integer
    field :type, :string
    field :username, :string

    has_one :user, CodeCorps.User

    timestamps()
  end

  @doc false
  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:avatar_url, :email, :github_id, :username, :type])
    |> validate_required([:avatar_url, :github_id, :username, :type])
  end
end
