defmodule CodeCorps.Preview do
    @moduledoc """
    Represents an category on Code Corps, e.g. "Society" and "Technology".
    """

  use CodeCorps.Web, :model

  alias CodeCorps.MarkdownRenderer

  schema "previews" do
    field :body, :string
    field :markdown, :string

    belongs_to :user, CodeCorps.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}, user) do
    struct
    |> cast(params, [:markdown])
    |> validate_required([:markdown])
    |> assign_user(user)
    |> MarkdownRenderer.render_markdown_to_html(:markdown, :body)
  end

  defp assign_user(changeset, nil), do: changeset
  defp assign_user(changeset, user) do
    changeset
    |> put_assoc(:user, user)
  end
end
