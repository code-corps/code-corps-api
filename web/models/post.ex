defmodule CodeCorps.Post do
  use CodeCorps.Web, :model

  schema "posts" do
    field :number, :integer
    field :title, :string
    field :post_type, :string
    field :state, :string
    field :status, :string
    field :body, :string
    field :markdown, :string
    field :likes_count, :integer
    field :comments_count, :integer
    belongs_to :user, CodeCorps.User

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:number, :title, :post_type, :body, :markdown])
    |> validate_required([:number, :title, :post_type, :body, :markdown])
    |> unique_constraint(:number)
  end
end
