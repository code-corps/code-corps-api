defmodule CodeCorpsWeb.Plug.DataToAttributes do
  @moduledoc ~S"""
  Converts params in the JSON api "data" format into flat params convient for
  changeset casting.

  This is done using `JaSerializer.Params.to_attributes/1`
  """

  alias Plug.Conn

  @spec init(Keyword.t) :: Keyword.t
  def init(opts), do: opts

  @spec call(Conn.t, Keyword.t) :: Plug.Conn.t
  def call(%Conn{params: %{"data" => data} = params} = conn, _opts) do
    attributes =
      params
      |> Map.delete("data")
      |> Map.merge(data |> JaSerializer.Params.to_attributes)

    conn |> Map.put(:params, attributes)
  end
  def call(%Conn{} = conn, _opts), do: conn
end
