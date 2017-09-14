defmodule CodeCorpsWeb.FallbackController do
  use CodeCorpsWeb, :controller

  alias Ecto.Changeset

  @type supported_fallbacks :: {:error, Changeset.t} |
                               {:error, :not_authorized} |
                               {:error, :github} |
                               nil

  @doc ~S"""
  Default fallback for different `with` clause errors in controllers across the
  application.
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
  def call(%Conn{} = conn, {:error, :github}) do
    conn
    |> put_status(500)
    |> render(CodeCorpsWeb.ErrorView, "500.json", message: "An unknown error occurred with GitHub's API.")
  end
end
