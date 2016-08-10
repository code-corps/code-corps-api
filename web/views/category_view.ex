defmodule CodeCorps.CategoryView do
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:name, :slug, :description]
end
