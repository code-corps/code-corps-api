defmodule CodeCorpsWeb.UserCategoryView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  has_one :user, type: "user", field: :user_id
  has_one :category, type: "category", field: :category_id
end
