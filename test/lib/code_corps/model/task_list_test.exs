defmodule CodeCorps.TaskListTest do
  use CodeCorps.ModelCase

  alias CodeCorps.TaskList
  alias Ecto.Changeset

  @valid_attrs %{name: "some content", position: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = TaskList.changeset(%TaskList{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = TaskList.changeset(%TaskList{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "defaults :done to 'false'" do
    {:ok, record} =
      %TaskList{} |> TaskList.changeset(@valid_attrs) |> Repo.insert
    assert record.done == false
  end

  test "defaults :inbox to 'false'" do
    {:ok, record} =
      %TaskList{} |> TaskList.changeset(@valid_attrs) |> Repo.insert
    assert record.inbox == false
  end

  test "defaults :pull_requests to 'false'" do
    {:ok, record} =
      %TaskList{} |> TaskList.changeset(@valid_attrs) |> Repo.insert
    assert record.pull_requests == false
  end

  describe "create_changeset" do
    test "casts done" do
      attrs = @valid_attrs |> Map.merge(%{done: true})
      changeset = %TaskList{} |> TaskList.create_changeset(attrs)
      assert changeset |> Changeset.get_change(:done) == true
    end

    test "casts inbox" do
      attrs = @valid_attrs |> Map.merge(%{inbox: true})
      changeset = %TaskList{} |> TaskList.create_changeset(attrs)
      assert changeset |> Changeset.get_change(:inbox) == true
    end

    test "casts pull_requests" do
      attrs = @valid_attrs |> Map.merge(%{pull_requests: true})
      changeset = %TaskList{} |> TaskList.create_changeset(attrs)
      assert changeset |> Changeset.get_change(:pull_requests) == true
    end

    test "requires done" do
      attrs = @valid_attrs |> Map.merge(%{done: nil})
      changeset = %TaskList{} |> TaskList.create_changeset(attrs)
      refute changeset.valid?
      assert changeset |> Map.get(:errors) |> Keyword.get(:done)
    end

    test "requires inbox" do
      attrs = @valid_attrs |> Map.merge(%{inbox: nil})
      changeset = %TaskList{} |> TaskList.create_changeset(attrs)
      refute changeset.valid?
      assert changeset |> Map.get(:errors) |> Keyword.get(:inbox)
    end

    test "requires pull_requests" do
      attrs = @valid_attrs |> Map.merge(%{pull_requests: nil})
      changeset = %TaskList{} |> TaskList.create_changeset(attrs)
      refute changeset.valid?
      assert changeset |> Map.get(:errors) |> Keyword.get(:pull_requests)
    end

    test "ensures a unique 'done' task list per project" do
      %{id: project_id} = insert(:project)
      attrs = @valid_attrs |> Map.merge(%{done: true})

      {:ok, _task_list} =
        %TaskList{}
        |> TaskList.create_changeset(attrs)
        |> Changeset.put_change(:project_id, project_id)
        |> Repo.insert

      {:error, changeset} =
        %TaskList{}
        |> TaskList.create_changeset(attrs)
        |> Changeset.put_change(:project_id, project_id)
        |> Repo.insert

      refute changeset.valid?
      assert changeset |> Map.get(:errors) |> Keyword.get(:done)
    end

    test "ensures a unique 'inbox' task list per project" do
      %{id: project_id} = insert(:project)
      attrs = @valid_attrs |> Map.merge(%{inbox: true})

      {:ok, _task_list} =
        %TaskList{}
        |> TaskList.create_changeset(attrs)
        |> Changeset.put_change(:project_id, project_id)
        |> Repo.insert

      {:error, changeset} =
        %TaskList{}
        |> TaskList.create_changeset(attrs)
        |> Changeset.put_change(:project_id, project_id)
        |> Repo.insert

      refute changeset.valid?
      assert changeset |> Map.get(:errors) |> Keyword.get(:inbox)
    end

    test "ensures a unique 'pull_requests' task list per project" do
      %{id: project_id} = insert(:project)
      attrs = @valid_attrs |> Map.merge(%{pull_requests: true})

      {:ok, _task_list} =
        %TaskList{}
        |> TaskList.create_changeset(attrs)
        |> Changeset.put_change(:project_id, project_id)
        |> Repo.insert

      {:error, changeset} =
        %TaskList{}
        |> TaskList.create_changeset(attrs)
        |> Changeset.put_change(:project_id, project_id)
        |> Repo.insert

      refute changeset.valid?
      assert changeset |> Map.get(:errors) |> Keyword.get(:pull_requests)
    end
  end
end
