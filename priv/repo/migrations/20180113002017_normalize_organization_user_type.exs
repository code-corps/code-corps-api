defmodule CodeCorps.Repo.Migrations.NormalizeOrganizationUserType do
  use Ecto.Migration

  def up do
    execute(
      """
      UPDATE github_users
      SET type = 'organization'
      WHERE type = 'Organization'
      """
    )
  end

  def down do
    execute(
      """
      UPDATE github_users
      SET type = 'Organization'
      WHERE type = 'organization'
      """
    )
  end
end
