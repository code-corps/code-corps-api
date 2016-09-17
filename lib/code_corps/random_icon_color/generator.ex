defmodule CodeCorps.RandomIconColor.Generator do
  def generate do
    ~w(blue green light_blue pink purple yellow) |> Enum.random
  end
end
