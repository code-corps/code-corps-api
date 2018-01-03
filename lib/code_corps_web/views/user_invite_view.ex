defmodule CodeCorpsWeb.UserInviteView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:email, :name, :role]

  has_one :invitee, type: "user", field: :invitee_id
  has_one :inviter, type: "user", field: :inviter_id
  has_one :project, type: "project", field: :project_id
end
