defmodule CodeCorps.Repo.Migrations.AddPostNumberIncrementing do
  use Ecto.Migration

  alias CodeCorps.Repo

  def up do
    # We need to assign the number to a post based on its project_id
    Ecto.Adapters.SQL.query(Repo,
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
      """, [], [])

    Ecto.Adapters.SQL.query(Repo,
      """
      CREATE TRIGGER post_created
        BEFORE INSERT ON posts
        FOR EACH ROW
        EXECUTE PROCEDURE assign_number();
      """, [], [])
  end

  def down do
    Ecto.Adapters.SQL.query(Repo,
      """
      DROP TRIGGER IF EXISTS post_created ON posts;
      """, [], [])

    Ecto.Adapters.SQL.query(Repo,
      """
      DROP FUNCTION IF EXISTS assign_number();
      """, [], [])
  end
end
