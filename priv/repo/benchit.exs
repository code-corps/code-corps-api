alias CodeCorps.{
  Category,Repo
}
import Phoenix.View, only: [render: 3]

# category = %Category{
#     id: 12
# }

category = Category |> Repo.get(12) |> Repo.preload([:project_categories])

Benchee.run(%{
    "jsonapi"    => fn -> render(CodeCorpsWeb.CategoryjsonapiView, "show.json-api", %{ data: category, conn: nil, params: category.id }) end,
    "existing"   => fn -> render(CodeCorpsWeb.CategoryView, "show.json-api", data: category) end
}, time: 10)