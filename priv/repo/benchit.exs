alias CodeCorps.{
  Category,Repo
}

category = %Category{
    id: 12
}

Benchee.run(%{
    "jsonapi"    => fn -> CodeCorpsWeb.CategoryController.show_with_jsonapi(%Plug.Conn{}, %{"id" => category.id}) end,
    "existing"   => fn -> CodeCorpsWeb.CategoryController.show(%Plug.Conn{}, %{"id" => category.id}) end
}, time: 10)