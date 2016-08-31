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

  describe "&create/2" do
    test "is invalid with invalid attributes" do
      changeset = Post.changeset(%Post{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "only allows specific values for post_type" do
      changes = Map.put(@valid_attrs, :post_type, "nonexistent")
      changeset = Post.changeset(%Post{}, changes)
      refute changeset.valid?
    end

    test "renders body html from markdown" do
      user = insert(:user)
      project = insert(:project)
      changes = Map.merge(@valid_attrs, %{
        markdown: "A **strong** body",
        project_id: project.id,
        user_id: user.id
      })
      changeset = Post.changeset(%Post{}, changes)
      assert changeset.valid?
      assert changeset |> get_change(:body) == "<p>A <strong>strong</strong> body</p>\n"
    end
  end

  describe "&create_changeset/2" do
    test "is valid with valid attributes" do
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

    test "auto-sequences number, scoped to project" do
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

    test "sets state to 'published'" do
      changeset = Post.create_changeset(%Post{}, %{})
      assert changeset |> get_change(:state) == "published"
    end

    test "sets status to 'open'" do
      changeset = Post.create_changeset(%Post{}, %{})
      # open is default, so we `get_field` instead of `get_change`
      assert changeset |> get_field(:status) == "open"
    end
  end
  describe "&update_changeset/2" do
    test "sets state to 'edited'" do
      changeset = Post.update_changeset(%Post{}, %{})
      assert changeset |> get_change(:state) == "edited"
    end

    test "only allows specific values for status" do
      changes = Map.put(@valid_attrs, :status, "nonexistent")
      changeset = Post.update_changeset(%Post{}, changes)
      refute changeset.valid?
    end
  end

end
