defmodule CodeCorps.Preview do
  @moduledoc """
  Represents an category on Code Corps, e.g. "Society" and "Technology".
  """

  use CodeCorps.Model
  alias CodeCorps.Services.MarkdownRendererService

  @type t :: %__MODULE__{}

  schema "previews" do
    field :body, :string
    field :markdown, :string

    belongs_to :user, CodeCorps.User

    timestamps(type: :utc_datetime)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:markdown, :user_id])
    |> validate_required([:markdown, :user_id])
    |> assoc_constraint(:user)
    |> MarkdownRendererService.render_markdown_to_html(:markdown, :body)
  end
end
