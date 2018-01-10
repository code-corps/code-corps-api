defmodule CodeCorps.Messages.Conversations do
  @moduledoc ~S"""
  Subcontext aimed at managing `CodeCorps.Conversation` records aimed at a
  specific user belonging to a `CodeCorps.Message`.
  """

  import Ecto.Query
  alias Ecto.Changeset

  alias CodeCorps.{Conversation, Project}

  @doc false
  @spec create_changeset(Conversation.t, map) :: Ecto.Changeset.t
  def create_changeset(%Conversation{} = conversation, %{} = attrs) do
    conversation
    |> Changeset.cast(attrs, [:user_id])
    |> Changeset.validate_required([:user_id])
    |> Changeset.assoc_constraint(:user)
    |> Changeset.prepare_changes(fn prepared_changeset -> 
      repo = prepared_changeset.repo
      project_id = prepared_changeset.project_id

      from(p in Project, where: p.id == ^project_id)
      |> repo.update_all(inc: [open_conversations_count: 1])

      prepared_changeset
    end)
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
