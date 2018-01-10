defmodule CodeCorps.Repo.Migrations.AddUserInvites do
  use Ecto.Migration

  def change do
    create table(:user_invites) do
      add(:email, :string, null: false)
      add(:name, :string, null: true)
      add(:role, :string, null: true)

      add(:inviter_id, references(:users))
      add(:invitee_id, references(:users))
      add(:project_id, references(:projects))

      timestamps()
    end
  end
end
