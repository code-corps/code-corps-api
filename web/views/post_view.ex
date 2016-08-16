defmodule CodeCorps.PostView do
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:body, :markdown, :number, :post_type, :status, :title, :inserted_at, :updated_at]
end
