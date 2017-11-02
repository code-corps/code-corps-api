alias CodeCorps.{
  TaskList,Repo
}
import Phoenix.View, only: [render: 3]

# category = %Category{
#     id: 12
# }

task_list = TaskList |> Repo.get(1) |> Repo.preload([:tasks])

Benchee.run(%{
    "jsonapi"    => fn -> render(CodeCorpsWeb.TaskListjsonapiView, "show.json-api", %{ data: task_list, conn: nil, params: task_list.id }) end,
    "existing"   => fn -> render(CodeCorpsWeb.TaskListView, "show.json-api", data: task_list) end
}, time: 10)