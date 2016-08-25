defmodule CodeCorps.PostTest do
  use CodeCorps.ModelCase

  alias CodeCorps.Post

  @valid_attrs %{
    title: "Test post",
    post_type: "issue",
    markdown: "A test post",
    status: "open"
  }
  @invalid_attrs %{
    post_type: "nonexistent",
    status: "nonexistent"
  }

  test "create changeset with valid attributes is valid" do
    user = insert(:user)
    project = insert(:project)
    changeset = Post.create_changeset(%Post{}, %{
      markdown: "some content",
      post_type: "issue",
      title: "some content",
      project_id: project.id,
      user_id: user.id,
      status: "open"
    })
    assert changeset.valid?
  end

  test "number is auto-sequenced scoped to project" do
    user = insert(:user)
    project_a = insert(:project, title: "Project A")
    project_b = insert(:project, title: "Project B")

    insert(:post, project: project_a, user: user, title: "Project A Post 1")
    insert(:post, project: project_a, user: user, title: "Project A Post 2")

    insert(:post, project: project_b, user: user, title: "Project B Post 1")

    changes = Map.merge(@valid_attrs, %{
      project_id: project_a.id,
      user_id: user.id
    })
    changeset = Post.create_changeset(%Post{}, changes)
    {:ok, result} = Repo.insert(changeset)
    result = Repo.get(Post, result.id)
    assert result.number == 3

    changes = Map.merge(@valid_attrs, %{
      project_id: project_b.id,
      user_id: user.id
    })
    changeset = Post.create_changeset(%Post{}, changes)
    {:ok, result} = Repo.insert(changeset)
    result = Repo.get(Post, result.id)
    assert result.number == 2
  end

  test "changeset with invalid attributes" do
    changeset = Post.changeset(%Post{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset, status not included" do
    changes = Map.put(@valid_attrs, :status, "nonexistent")
    changeset = Post.changeset(%Post{}, changes)
    refute changeset.valid?
  end

  test "changeset, post_type not included" do
    changes = Map.put(@valid_attrs, :post_type, "nonexistent")
    changeset = Post.changeset(%Post{}, changes)
    refute changeset.valid?
  end

  test "changeset renders body html from markdown" do
    user = insert(:user)
    project = insert(:project)
    changes = Map.merge(@valid_attrs, %{
      markdown: "A **strong** body",
      project_id: project.id,
      user_id: user.id
    })
    changeset = Post.create_changeset(%Post{}, changes)
    assert changeset.valid?
    assert changeset |> get_change(:body) == "<p>A <strong>strong</strong> body</p>\n"
  end
end
