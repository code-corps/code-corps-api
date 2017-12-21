defmodule CodeCorps.Messages.Conversations do
  @moduledoc ~S"""
  Subcontext aimed at managing `CodeCorps.Conversation` records aimed at a
  specific user belonging to a `CodeCorps.Message`.
  """

  alias Ecto.Changeset

  alias CodeCorps.{Conversation}

  @doc false
  @spec create_changeset(Conversation.t, map) :: Ecto.Changeset.t
  def create_changeset(%Conversation{} = conversation, %{} = attrs) do
    conversation
    |> Changeset.cast(attrs, [:user_id])
    |> Changeset.validate_required([:user_id])
    |> Changeset.assoc_constraint(:user)
  end
end
