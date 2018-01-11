defmodule CodeCorps.Presenters.ImagePresenterTest do
  use ExUnit.Case, async: true

  import CodeCorps.Factories

  alias CodeCorps.Presenters.ImagePresenter

  @organization build(:organization)
  @project build(:project)
  @user build(:user)

  describe "large/1" do
    test "returns proper large image defaults for organization" do
      assert ImagePresenter.large(@organization) == "#{Application.get_env(:code_corps, :asset_host)}/icons/organization_default_large_.png"
    end

    test "returns proper large image defaults for project" do
      assert ImagePresenter.large(@project) == "#{Application.get_env(:code_corps, :asset_host)}/icons/project_default_large_.png"
    end

    test "returns proper large image defaults for user" do
      assert ImagePresenter.large(@user) == "#{Application.get_env(:code_corps, :asset_host)}/icons/user_default_large_.png"
    end
  end

  describe "thumbnail/1" do
    test "returns proper thumbnail image defaults for organization" do
      assert ImagePresenter.thumbnail(@organization) == "#{Application.get_env(:code_corps, :asset_host)}/icons/organization_default_thumb_.png"
    end

    test "returns proper thumbnail image defaults for project" do
      assert ImagePresenter.thumbnail(@project) == "#{Application.get_env(:code_corps, :asset_host)}/icons/project_default_thumb_.png"
    end

    test "returns proper thumbnail image defaults for user" do
      assert ImagePresenter.thumbnail(@user) == "#{Application.get_env(:code_corps, :asset_host)}/icons/user_default_thumb_.png"
    end
  end
end
