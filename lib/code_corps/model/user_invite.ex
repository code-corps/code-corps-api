defmodule CodeCorps.UserInvite do
  use CodeCorps.Model

  @type t :: %__MODULE__{}

  schema "user_invites" do
    field(:email, :string, null: false)
    field(:role, :string)
    field(:name, :string)

    belongs_to(:project, CodeCorps.Project)
    belongs_to(:inviter, CodeCorps.User)
    belongs_to(:invitee, CodeCorps.User)

    timestamps()
  end
end
