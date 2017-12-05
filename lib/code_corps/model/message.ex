defmodule CodeCorps.Message do
  @moduledoc """
  A message sent from a project to a user or from a user to a project.

  The author does not need to be a member of the project in order to send a
  message to the project.

  No recipient will be defined for the message. The recipient is defined at the
  level of the `CodeCorps.Conversation`.

  A message may be used as a broadcast to a number of users. A message MAY
  therefore have many conversations associated with it.
  """

  use CodeCorps.Model
  alias CodeCorps.Message

  @type t :: %__MODULE__{}

  schema "messages" do
    field :body, :string
    field :initiated_by, :string
    field :subject, :string

    belongs_to :author, CodeCorps.User
    belongs_to :project, CodeCorps.Project

    timestamps()
  end

  @doc false
  @spec changeset(Message.t, map) :: Ecto.Changeset.t
  def changeset(%Message{} = message, attrs) do
    message
    |> cast(attrs, [:body, :initiated_by, :subject])
    |> validate_required([:body, :initiated_by])
    |> validate_inclusion(:initiated_by, initiated_by_sources())
    |> require_subject_if_admin()
  end

  # validate subject only if initiated_by "admin"
  @spec require_subject_if_admin(Ecto.Changeset.t) :: Ecto.Changeset.t
  defp require_subject_if_admin(changeset) do
    initiated_by = changeset |> Ecto.Changeset.get_field(:initiated_by)
    changeset |> do_require_subject_if_admin(initiated_by)
  end

  defp do_require_subject_if_admin(changeset, "admin") do
    changeset |> validate_required(:subject)
  end
  defp do_require_subject_if_admin(changeset, _), do: changeset

  @spec initiated_by_sources :: list(String.t)
  defp initiated_by_sources do
    ~w{ admin user }
  end
end
