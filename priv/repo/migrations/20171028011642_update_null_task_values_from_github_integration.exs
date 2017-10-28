defmodule CodeCorps.Repo.Migrations.UpdateNullTaskValuesFromGithubIntegration do
  use Ecto.Migration

  @consecutive_whitespace_regex ~r/\s+/

  def up do
    execute created_at_update()
    execute created_from_update()

    execute modified_at_update()
    execute modified_from_update()
  end

  def down do
    # no-op
  end

  defp created_at_update do
    squish(
      """
        UPDATE tasks
        SET created_at = inserted_at
        WHERE created_at IS NULL
      """
    )
  end

  defp created_from_update do
    squish(
      """
        UPDATE tasks
        SET created_from = 'code_corps'
        WHERE created_from IS NULL
      """
    )
  end

  defp modified_at_update do
    squish(
      """
        UPDATE tasks
        SET modified_at = updated_at
        WHERE modified_at IS NULL
      """
    )
  end

  defp modified_from_update do
    squish(
      """
        UPDATE tasks
        SET modified_from = 'code_corps'
        WHERE modified_from IS NULL
      """
    )
  end

  defp squish(query) do
    String.replace(query, @consecutive_whitespace_regex, " ") |> String.trim
  end
end
