defmodule CodeCorps.Repo.Migrations.AddNotNullConstraints do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE comments ALTER COLUMN user_id SET NOT NULL, ALTER COLUMN task_id SET NOT NULL"
    execute "ALTER TABLE organizations ALTER COLUMN name SET NOT NULL, ALTER COLUMN description SET NOT NULL, ALTER COLUMN slug SET NOT NULL"
    execute "ALTER TABLE previews ALTER COLUMN user_id SET NOT NULL"
    execute "ALTER TABLE project_skills ALTER COLUMN project_id SET NOT NULL, ALTER COLUMN skill_id SET NOT NULL"
    execute "ALTER TABLE projects ALTER COLUMN organization_id SET NOT NULL"
    execute "ALTER TABLE role_skills ALTER COLUMN role_id SET NOT NULL, ALTER COLUMN skill_id SET NOT NULL"
    execute "ALTER TABLE slugged_routes ALTER COLUMN slug SET NOT NULL"
    execute "ALTER TABLE tasks ALTER COLUMN title SET NOT NULL, ALTER COLUMN state SET NOT NULL"
    execute "ALTER TABLE user_categories ALTER COLUMN user_id SET NOT NULL, ALTER COLUMN category_id SET NOT NULL"
    execute "ALTER TABLE user_roles ALTER COLUMN user_id SET NOT NULL, ALTER COLUMN role_id SET NOT NULL"
    execute "ALTER TABLE user_skills ALTER COLUMN user_id SET NOT NULL, ALTER COLUMN skill_id SET NOT NULL"
  end

  def down do
    execute "ALTER TABLE comments ALTER COLUMN user_id DROP NOT NULL, ALTER COLUMN task_id DROP NOT NULL"
    execute "ALTER TABLE organizations ALTER COLUMN name DROP NOT NULL, ALTER COLUMN description DROP NOT NULL, ALTER COLUMN slug DROP NOT NULL"
    execute "ALTER TABLE previews ALTER COLUMN user_id DROP NOT NULL"
    execute "ALTER TABLE project_skills ALTER COLUMN project_id DROP NOT NULL, ALTER COLUMN skill_id DROP NOT NULL"
    execute "ALTER TABLE projects ALTER COLUMN organization_id DROP NOT NULL"
    execute "ALTER TABLE role_skills ALTER COLUMN role_id DROP NOT NULL, ALTER COLUMN skill_id DROP NOT NULL"
    execute "ALTER TABLE slugged_routes ALTER COLUMN slug DROP NOT NULL"
    execute "ALTER TABLE tasks ALTER COLUMN title DROP NOT NULL, ALTER COLUMN state DROP NOT NULL"
    execute "ALTER TABLE tasks ALTER COLUMN user_id DROP NOT NULL, ALTER COLUMN category_id DROP NOT NULL"
    execute "ALTER TABLE user_roles ALTER COLUMN user_id DROP NOT NULL, ALTER COLUMN role_id DROP NOT NULL"
    execute "ALTER TABLE user_skills ALTER COLUMN user_id DROP NOT NULL, ALTER COLUMN skill_id DROP NOT NULL"
  end
end
