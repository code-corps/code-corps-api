defmodule CodeCorps.Policy.HelpersTest do
  use CodeCorps.ModelCase
  alias Ecto.Changeset
  alias CodeCorps.{
    Organization, User, Policy.Helpers,
    ProjectUser
  }

  def create_project_user_with_role(role) do
    user = insert(:user)
    project = insert(:project)
    insert(:project_user, project: project, user: user, role: role)
    {project, user}
  end

  describe "owned_by/2" do
    test "returns false when organization is not owned by user" do
      refute Helpers.owned_by?(%Organization{owner_id: 1}, %User{id: 2})
    end

    test "returns false when invalid arguments are passed" do
      refute Helpers.owned_by?(nil, 2)
    end

    test "returns false if a project is not owned by the user" do
      project = insert(:project)
      some_other_user = %User{id: 1}
      refute Helpers.owned_by?(project, some_other_user)
    end

    test "returns true if a project is owned by the user" do
      {project, user} = create_project_user_with_role("owner")
      assert Helpers.owned_by?(project, user)
    end

    test "returns false if a project is admined by the user" do
      {project, user} = create_project_user_with_role("admin")
      refute Helpers.owned_by?(project, user)
    end

    test "returns false if a project is contributed by the user" do
      {project, user} = create_project_user_with_role("contributor")
      refute Helpers.owned_by?(project, user)
    end

    test "returns false if a project user role is pending" do
      {project, user} = create_project_user_with_role("pending")
      refute Helpers.owned_by?(project, user)
    end

    test "returns true when organization is owned by user" do
      assert Helpers.owned_by?(%Organization{owner_id: 1}, %User{id: 1})
    end
  end

  describe "administered_by?/2" do
    test "returns false if given invalid arguments" do
      refute Helpers.administered_by?(nil, 2)
    end

    test "returns true if the user is an admin" do
      {project, user} = create_project_user_with_role("admin")
      assert Helpers.administered_by?(project, user)
    end

    test "returns true if the user is an owner" do
      {project, user} = create_project_user_with_role("admin")
      assert Helpers.administered_by?(project, user)
    end

    test "returns false if the user is a contributor" do
      {project, user} = create_project_user_with_role("contributor")
      refute Helpers.administered_by?(project, user)
    end

    test "returns false if the user is pending" do
      {project, user} = create_project_user_with_role("pending")
      refute Helpers.administered_by?(project, user)
    end
  end

  describe "contributed_by?/2" do
    test "returns false if given invalid arguments" do
      refute Helpers.contributed_by?(nil, 2)
    end

    test "returns true if the user is an admin" do
      {project, user} = create_project_user_with_role("admin")
      assert Helpers.contributed_by?(project, user)
    end

    test "returns true if the user is an owner" do
      {project, user} = create_project_user_with_role("admin")
      assert Helpers.contributed_by?(project, user)
    end

    test "returns true if the user is a contributor" do
      {project, user} = create_project_user_with_role("contributor")
      assert Helpers.contributed_by?(project, user)
    end

    test "returns false if the user is pending" do
      {project, user} = create_project_user_with_role("pending")
      refute Helpers.contributed_by?(project, user)
    end
  end

  describe "get_conversation/1" do
    test "should return conversation of a map" do
      conversation = insert(:conversation)
      result = Helpers.get_conversation(%{"conversation_id" => conversation.id})
      assert result.id == conversation.id
    end

    test "should return conversation of a ConversationPart" do
      conversation = insert(:conversation)
      conversation_part = insert(:conversation_part, conversation: conversation)
      result = Helpers.get_conversation(conversation_part)
      assert result.id == conversation.id
    end

    test "should return conversation of a Changeset" do
      conversation = insert(:conversation)
      changeset = %Changeset{changes: %{conversation_id: conversation.id}}
      result = Helpers.get_conversation(changeset)
      assert result.id == conversation.id
    end
  end

  describe "get_organization/1" do
    test "return organization if the organization_id is defined on the struct" do
      organization = insert(:organization)
      project = insert(:project, organization: organization)
      result = Helpers.get_organization(project)
      assert result.id == organization.id
      assert result.name == organization.name
    end

    test "return organization if the organization_id is defined on the changeset" do
      organization = insert(:organization)
      changeset = %Changeset{changes: %{organization_id: organization.id}}
      result = Helpers.get_organization(changeset)
      assert result.id == organization.id
      assert result.name == organization.name
    end

    test "return nil for structs with no organization_id" do
      assert Helpers.get_organization(%{foo: "bar"}) == nil
    end

    test "return nil for any" do
      assert Helpers.get_organization("foo") == nil
    end
  end

  describe "get_message/1" do
    test "should return message of a map" do
      message = insert(:message)
      result = Helpers.get_message(%{"message_id" => message.id})
      assert result.id == message.id
    end

    test "should return message of a Conversation" do
      message = insert(:message)
      conversation = insert(:conversation, message: message)
      result = Helpers.get_message(conversation)
      assert result.id == message.id
    end

    test "should return message of a Changeset" do
      message = insert(:message)
      changeset = %Changeset{changes: %{message_id: message.id}}
      result = Helpers.get_message(changeset)
      assert result.id == message.id
    end
  end

  describe "get_project/1" do
    test "return project if the project_id is defined on the struct" do
      project = insert(:project)
      project_category = insert(:project_category, project: project)
      result = Helpers.get_project(project_category)
      assert result.id == project.id
      assert result.title == project.title
    end

    test "return project if the project_id is defined on the changeset" do
      project = insert(:project)
      changeset = %Changeset{changes: %{project_id: project.id}}
      result = Helpers.get_project(changeset)
      assert result.id == project.id
      assert result.title == project.title
    end

    test "return nil for structs with no project_id" do
      assert Helpers.get_project(%{foo: "bar"}) == nil
    end

    test "return nil for any" do
      assert Helpers.get_project("foo") == nil
    end
  end

  describe "get_role/1" do
    test "should return a project user's role if it's defined" do
      assert Helpers.get_role(%ProjectUser{role: "admin"}) == "admin"
    end

    test "should return a changeset's role if it's defined" do
      assert Helpers.get_role(%Changeset{data: %{role: "contributor"}, types: %{role: :string}}) == "contributor"
    end

    test "should return nil if no role is defined on a project user" do
      assert Helpers.get_role(%ProjectUser{}) == nil
    end

    test "should return nil if no role is defined on a changeset" do
      assert Helpers.get_role(%Changeset{data: %{role: nil}, types: %{role: :string}}) == nil
    end

    test "should return nil if nil is passed in" do
      assert Helpers.get_role(nil) == nil
    end
  end

  describe "get_task/1" do
    test "should return task of a TaskSkill" do
      task = insert(:task)
      task_skill = insert(:task_skill, task: task)
      result = Helpers.get_task(task_skill)
      assert result.id == task.id
    end

    test "should return task of a UserTask" do
      task = insert(:task)
      user_task = insert(:user_task, task: task)
      result = Helpers.get_task(user_task)
      assert result.id == task.id
    end

    test "should return task of a Changeset" do
      task = insert(:task)
      changeset = %Changeset{changes: %{task_id: task.id}}
      result = Helpers.get_task(changeset)
      assert result.id == task.id
    end
  end

  describe "task_authored_by?/1" do
    test "returns true if the user is the author of the task" do
      user = insert(:user)
      task = insert(:task, user: user)
      assert Helpers.task_authored_by?(task, user)
    end

    test "returns false if the user is not the author of the task" do
      user = insert(:user)
      other_user = insert(:user)
      task = insert(:task, user: user)
      refute Helpers.task_authored_by?(task, other_user)
    end
  end
end
