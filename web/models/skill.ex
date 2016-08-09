defmodule CodeCorps.Skill do
  use CodeCorps.Web, :model
  import Inflex

  schema "skills" do
    field :title, :string
    field :description, :string
    field :original_row, :integer
    field :slug, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :description, :original_row, :slug])
    |> update_slug()
    |> validate_required([:title, :slug])
    |> validate_exclusion(:slug, reserved_routes)
    |> unique_constraint(:slug)
  end

  def update_slug(changeset) do
    case changeset do
      %Ecto.Changeset{changes: %{title: title}} ->
        slug = Inflex.parameterize(title)
        put_change(changeset, :slug, slug)
      _ ->
        changeset
    end

  end

  def reserved_routes do
    ~w(
      about account admin android api app apps blog bug bugs cache charter
      comment comments contact contributor contributors cookies
      developer developers discover donate engineering enterprise explore
      facebook favorites feed followers following github help home image images
      integration integrations invite invitations ios issue issues jobs learn
      likes lists log-in log-out login logout mention mentions new news
      notification notifications oauth oauth_clients organization organizations
      ping popular post_image post_images post_like post_likes post post
      press pricing privacy
      project projects repositories role roles rules search security session
      sessions settings shop showcases sidekiq sign-in sign-out signin signout
      signup sitemap slug slugs spotlight stars status tag tags
      tasks team teams terms training trends trust tour twitter
      user_role user_roles user_skill user_skills user users watching year
    )
  end
end
