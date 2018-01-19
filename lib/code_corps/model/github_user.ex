defmodule CodeCorps.GithubUser do
  use Ecto.Schema

  @type t :: %__MODULE__{}

  schema "github_users" do
    field :avatar_url, :string
    field :email, :string
    field :github_id, :integer
    field :type, :string
    field :username, :string

    has_one :user, CodeCorps.User

    timestamps()
  end
end
