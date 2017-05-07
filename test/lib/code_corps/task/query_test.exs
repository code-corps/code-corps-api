defmodule CodeCorps.Task.QueryTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  alias CodeCorps.Task

  describe "filter/2" do
    defp get_sorted_ids(tasks) do
      tasks |> Enum.map(&Map.get(&1, :id)) |> Enum.sort
    end

    defp filter_sorted_ids(params) do
      Task |> Task.Query.filter(params) |> Repo.all |> get_sorted_ids()
    end

    defp find_with_query(params) do
      Task |> Task.Query.query(params) |> Repo.one
    end

    test "filters by project_id" do
      project_1 = insert(:project)
      project_1_tasks = insert_list(3, :task, project: project_1)
      project_1_task_ids = project_1_tasks |> get_sorted_ids()

      project_2 = insert(:project)
      project_2_tasks = insert_list(3, :task, project: project_2)
      project_2_task_ids = project_2_tasks |> get_sorted_ids()

      assert project_1_task_ids ==
        filter_sorted_ids(%{"project_id" => project_1.id})

      assert project_2_task_ids ==
        filter_sorted_ids(%{"project_id" => project_2.id})
    end

    test "filters by coalesced task_list_ids" do
      task_list_1 = insert(:task_list)
      list_1_tasks = insert_list(3, :task, task_list: task_list_1)
      list_1_task_ids = list_1_tasks |> get_sorted_ids()

      task_list_2 = insert(:task_list)
      list_2_tasks = insert_list(3, :task, task_list: task_list_2)
      list_2_task_ids = list_2_tasks |> get_sorted_ids()

      task_list_3 = insert(:task_list)
      list_3_tasks = insert_list(3, :task, task_list: task_list_3)
      list_3_task_ids = list_3_tasks |> get_sorted_ids()

      assert list_1_task_ids ==
        filter_sorted_ids(%{"task_list_ids" => "#{task_list_1.id}"})

      assert list_2_task_ids ==
        filter_sorted_ids(%{"task_list_ids" => "#{task_list_2.id}"})

      assert list_3_task_ids ==
        filter_sorted_ids(%{"task_list_ids" => "#{task_list_3.id}"})

      assert (list_1_task_ids ++ list_2_task_ids) |> Enum.sort ==
        filter_sorted_ids(%{"task_list_ids" => "#{task_list_1.id},#{task_list_2.id}"})

      assert (list_2_task_ids ++ list_3_task_ids) |> Enum.sort ==
        filter_sorted_ids(%{"task_list_ids" => "#{task_list_2.id},#{task_list_3.id}"})

      assert (list_1_task_ids ++ list_3_task_ids) |> Enum.sort ==
        filter_sorted_ids(%{"task_list_ids" => "#{task_list_1.id},#{task_list_3.id}"})
    end

    test "filters by status" do
      open_tasks = insert_list(3, :task, status: "open")
      open_task_ids = open_tasks |> get_sorted_ids()

      closed_tasks = insert_list(3, :task, status: "closed")
      closed_task_ids = closed_tasks |> get_sorted_ids()

      assert open_task_ids ==
        filter_sorted_ids(%{"status" => "open"})

      assert closed_task_ids ==
        filter_sorted_ids(%{"status" => "closed"})
    end

    test "works with multiple filters" do
      project_1 = insert(:project)
      project_2 = insert(:project)

      list_1 = insert(:task_list)
      list_2 = insert(:task_list)

      task_1 = insert(:task, status: "open", project: project_1, task_list: list_1)
      task_2 = insert(:task, status: "closed", project: project_1, task_list: list_1)
      task_3 = insert(:task, status: "open", project: project_1, task_list: list_2)
      task_4 = insert(:task, status: "closed", project: project_1, task_list: list_2)

      task_5 = insert(:task, status: "open", project: project_2, task_list: list_1)
      task_6 = insert(:task, status: "closed", project: project_2, task_list: list_1)
      task_7 = insert(:task, status: "open", project: project_2, task_list: list_2)
      task_8 = insert(:task, status: "closed", project: project_2, task_list: list_2)

      assert [task_1.id] ==
        filter_sorted_ids(%{"status" => "open", "project_id" => project_1.id, "task_list_ids" => "#{list_1.id}"})

      assert [task_2.id] ==
        filter_sorted_ids(%{"status" => "closed", "project_id" => project_1.id, "task_list_ids" => "#{list_1.id}"})

      assert [task_1, task_2] |> get_sorted_ids() ==
        filter_sorted_ids(%{"project_id" => project_1.id, "task_list_ids" => "#{list_1.id}"})

      assert [task_1, task_5] |> get_sorted_ids() ==
        filter_sorted_ids(%{"status" => "open", "task_list_ids" => "#{list_1.id}"})

      assert [task_1, task_3, task_5, task_7] |> get_sorted_ids() ==
        filter_sorted_ids(%{"status" => "open", "task_list_ids" => "#{list_1.id},#{list_2.id}"})

      assert [task_2, task_4, task_6, task_8] |> get_sorted_ids() ==
        filter_sorted_ids(%{"status" => "closed", "task_list_ids" => "#{list_1.id},#{list_2.id}"})

      assert [task_1, task_3] |> get_sorted_ids() ==
        filter_sorted_ids(%{"status" => "open", "project_id" => project_1.id})
    end
  end

  describe "query/2" do
    test "queries by project_id and id as number" do
      [task, _] = insert_pair(:task)
      retrieved_task =
        find_with_query(%{"id" => task.number, "project_id" => task.project_id})

      assert retrieved_task.id == task.id
    end

    test "queries by task_list_id and id as number" do
      [task, _] = insert_pair(:task)
      retrieved_task =
        find_with_query(%{"id" => task.number, "task_list_id" => task.task_list_id})

      assert retrieved_task.id == task.id
    end

    test "queries by id" do
      [task, _] = insert_pair(:task)
      retrieved_task = find_with_query(%{"id" => task.id})
      assert retrieved_task.id == task.id
    end
  end
end
