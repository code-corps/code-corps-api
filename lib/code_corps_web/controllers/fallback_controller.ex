defmodule CodeCorpsWeb.FallbackController do
  use CodeCorpsWeb, :controller

  alias Ecto.Changeset

  @type supported_fallbacks :: {:error, Changeset.t} |
                               {:error, :not_authorized} |
                               nil

  @doc ~S"""
  Default fallback for validation errors.

  Renders validation errors for the provided changeset using `JaSerializer`
  """
  @spec call(Conn.t, supported_fallbacks) :: Conn.t
  def call(%Conn{} = conn, {:error, %Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(:errors, data: changeset)
  end
  def call(%Conn{} = conn, {:error, :not_authorized}) do
    conn
    |> put_status(403)
    |> render(CodeCorpsWeb.TokenView, "403.json", message: "You are not authorized to perform this action.")
  end
  def call(%Conn{} = conn, nil) do
    conn
    |> put_status(:not_found)
    |> render(CodeCorpsWeb.ErrorView, "404.json")
  end
end
