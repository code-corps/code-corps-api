defmodule CodeCorpsWeb.PreloadHelpers do
  defmacro __using__(default_preloads: preloads) do
    quote do
      def preload(query, _conn, []) do
        query |> CodeCorps.Repo.preload(unquote(preloads))
      end
    end
  end
end
