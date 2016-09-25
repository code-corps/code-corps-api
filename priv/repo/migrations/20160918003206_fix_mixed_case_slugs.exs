defmodule CodeCorps.Repo.Migrations.FixMixedCaseSlugs do
  use Ecto.Migration

  alias CodeCorps.Repo
  alias CodeCorps.SluggedRoute

  def up do
    SluggedRoute
    |> Repo.all
    |> Repo.preload([:user, :organization])
    |> Enum.each(fn record ->
      SluggedRoute.changeset(record)
      |> Ecto.Changeset.put_change(:slug, Inflex.parameterize(record.slug))
      |> Repo.update!
    end)
  end

  def down do
    # Nothing to do here
  end
end
