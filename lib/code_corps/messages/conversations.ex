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

  @doc false
  @spec part_added_changeset(Conversation.t) :: Ecto.Changeset.t
  def part_added_changeset(%Conversation{} = conversation) do
    params = %{
      status: "open",
      updated_at: Ecto.DateTime.utc()
    }

    conversation
    |> Changeset.cast(params, [:status, :updated_at])
  end
end
