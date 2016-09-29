defmodule CodeCorps.Repo.Migrations.ChangePostsToTasks do
  use Ecto.Migration

  def up do
    execute(
      """
      DROP TRIGGER IF EXISTS post_created ON posts;
      """
    )

    execute(
      """
      DROP FUNCTION IF EXISTS assign_number();
      """
    )

    execute "ALTER TABLE comments DROP CONSTRAINT comments_post_id_fkey"

    execute "ALTER TABLE posts DROP CONSTRAINT IF EXISTS posts_pkey"

    execute "DROP INDEX IF EXISTS posts_pkey"

    drop_if_exists index(:posts, [:project_id])
    drop_if_exists index(:posts, [:user_id])
    drop_if_exists index(:posts, [:number, :project_id], unique: true)

    drop_if_exists index(:comments, [:post_id])

    rename table(:posts), to: table(:tasks)

    execute "CREATE UNIQUE INDEX tasks_pkey ON tasks USING btree (id)"

    execute "ALTER SEQUENCE posts_id_seq RENAME TO tasks_id_seq"

    rename table(:comments), :post_id, to: :task_id

    create index(:comments, [:task_id])

    alter table(:comments) do
      modify :task_id, references(:tasks, on_delete: :delete_all)
    end

    rename table(:tasks), :post_type, to: :task_type

    execute "ALTER TABLE tasks RENAME CONSTRAINT posts_project_id_fkey TO tasks_project_id_fkey"
    execute "ALTER TABLE tasks RENAME CONSTRAINT posts_user_id_fkey TO tasks_user_id_fkey"

    create index(:tasks, [:project_id])
    create index(:tasks, [:user_id])
    create index(:tasks, [:number, :project_id], unique: true)

    # We need to assign the number to a task based on its project_id
    execute(
      """
      CREATE OR REPLACE FUNCTION assign_number()
        RETURNS trigger AS
      $BODY$
      DECLARE
        max_number integer;
      BEGIN
        SELECT coalesce(MAX(number), 0) INTO max_number FROM tasks WHERE project_id = NEW.project_id;
        NEW.number := max_number + 1;
        RETURN NEW;
      END;
      $BODY$ LANGUAGE plpgsql;
      """
    )

    execute(
      """
      CREATE TRIGGER task_created
        BEFORE INSERT ON tasks
        FOR EACH ROW
        EXECUTE PROCEDURE assign_number();
      """
    )
  end

  def down do
    execute(
      """
      DROP TRIGGER IF EXISTS task_created ON tasks;
      """
    )

    execute(
      """
      DROP FUNCTION IF EXISTS assign_number();
      """
    )

    execute "ALTER TABLE comments DROP CONSTRAINT comments_task_id_fkey"

    execute "DROP INDEX tasks_pkey"

    drop_if_exists index(:tasks, [:id])
    drop_if_exists index(:tasks, [:project_id])
    drop_if_exists index(:tasks, [:user_id])
    drop_if_exists index(:tasks, [:number, :project_id], unique: true)

    drop_if_exists index(:comments, [:task_id])

    rename table(:tasks), to: table(:posts)

    execute "CREATE UNIQUE INDEX posts_pkey ON posts USING btree (id)"

    execute "ALTER SEQUENCE tasks_id_seq RENAME TO posts_id_seq"

    rename table(:comments), :task_id, to: :post_id

    create index(:comments, [:post_id])

    alter table(:comments) do
      modify :post_id, references(:posts, on_delete: :delete_all)
    end

    rename table(:posts), :task_type, to: :post_type

    execute "ALTER TABLE posts RENAME CONSTRAINT tasks_project_id_fkey TO posts_project_id_fkey"
    execute "ALTER TABLE posts RENAME CONSTRAINT tasks_user_id_fkey TO posts_user_id_fkey"

    create index(:posts, [:project_id])
    create index(:posts, [:user_id])
    create index(:posts, [:number, :project_id], unique: true)

    # We need to assign the number to a post based on its project_id
    execute(
      """
      CREATE OR REPLACE FUNCTION assign_number()
        RETURNS trigger AS
      $BODY$
      DECLARE
        max_number integer;
      BEGIN
        SELECT coalesce(MAX(number), 0) INTO max_number FROM posts WHERE project_id = NEW.project_id;
        NEW.number := max_number + 1;
        RETURN NEW;
      END;
      $BODY$ LANGUAGE plpgsql;
      """
    )

    execute(
      """
      CREATE TRIGGER post_created
        BEFORE INSERT ON posts
        FOR EACH ROW
        EXECUTE PROCEDURE assign_number();
      """
    )
  end
end
