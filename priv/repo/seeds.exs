alias CodeCorps.{
  Category, Organization, ProjectUser, Project, ProjectCategory, ProjectSkill,
  Repo, Role, Skill, Task, User, UserCategory, UserRole, UserSkill
}

# Users

users = [
  %{
    email: "owner@codecorps.org",
    first_name: "Code Corps",
    last_name: "Owner",
    password: "password",
    username: "codecorps-owner"
  },
  %{
    email: "admin@codecorps.org",
    first_name: "Code Corps",
    last_name: "Admin",
    password: "password",
    username: "codecorps-admin"
  },
  %{
    email: "contributor@codecorps.org",
    first_name: "Code Corps",
    last_name: "Contributor",
    password: "password",
    username: "codecorps-contributor"
  },
  %{
    email: "pending@codecorps.org",
    first_name: "Code Corps",
    last_name: "Pending",
    password: "password",
    username: "codecorps-pending"
  }
]

cond do
  Repo.all(User) != [] ->
    IO.puts "Users detected, aborting user seed."
  true ->
    Enum.each(users, fn user ->
      result =
        %User{}
        |> User.registration_changeset(user)
        |> Repo.insert!

      result
      |> User.update_changeset(user)
      |> Repo.update!
    end)
end

# Organizations

organizations = [
  %{
    name: "Code Corps",
    description: "Help build and fund public software projects for social good",
    owner_id: 1
  },
]

cond do
  Repo.all(Organization) != [] ->
    IO.puts "Organizations detected, aborting organization seed."
  true ->
    Enum.each(organizations, fn organization ->
      Organization.create_changeset(%Organization{}, organization)
      |> Repo.insert!
    end)
end

# Projects

projects = [
  %{
    title: "Code Corps",
    description: "A basic project for use in development",
    organization_id: 1,
    owner_id: 1
  }
]

cond do
  Repo.all(Project) != [] ->
    IO.puts "Projects detected, aborting project seed."
  true ->
    Enum.each(projects, fn project ->
      Project.create_changeset(%Project{}, project)
      |> Repo.insert!
    end)

    Project |> Repo.update_all(set: [approved: true])
end

# Skills

skills = [
  %{
    title: "CSS",
    },
  %{
    title: "Docker",
  },
  %{
    title: "Ember.js",
  },
  %{
    title: "HTML",
  },
  %{
    title: "Ruby",
  },
  %{
    title: "Ruby on Rails",
  },
]

cond do
  Repo.all(Skill) != [] ->
    IO.puts "Skills detected, aborting skill seed."
  true ->
    Enum.each(skills, fn skill ->
      Skill.changeset(%Skill{}, skill)
      |> Repo.insert!
    end)
end

# Roles

roles = [
  %{
    name: "Accountant",
    ability: "Accounting",
    kind: "support",
  },
  %{
    name: "Administrator",
    ability: "Administrative",
    kind: "support",
  },
  %{
    name: "Donor",
    ability: "Donations",
    kind: "support",
  },
  %{
    name: "Backend Developer",
    ability: "Backend Development",
    kind: "technology",
  },
  %{
    name: "Data Scientist",
    ability: "Data Science",
    kind: "technology",
  },
  %{
    name: "Designer",
    ability: "Design",
    kind: "creative",
  },
  %{
    name: "DevOps",
    ability: "DevOps",
    kind: "technology",
  },
  %{
    name: "Front End Developer",
    ability: "Front End Development",
    kind: "technology",
  },
  %{
    name: "Lawyer",
    ability: "Legal",
    kind: "support",
  },
  %{
    name: "Marketer",
    ability: "Marketing",
    kind: "creative",
  },
  %{
    name: "Mobile Developer",
    ability: "Mobile Development",
    kind: "technology",
  },
  %{
    name: "Product Manager",
    ability: "Product Management",
    kind: "technology",
  },
  %{
    name: "Photographer",
    ability: "Photography",
    kind: "creative",
  },
  %{
    name: "Researcher",
    ability: "Research",
    kind: "support",
  },
  %{
    name: "Tester",
    ability: "Testing",
    kind: "technology",
  },
  %{
    name: "Video Producer",
    ability: "Video Production",
    kind: "creative",
  },
  %{
    name: "Writer",
    ability: "Writing",
    kind: "creative",
  },
]

cond do
  Repo.all(Role) != [] ->
    IO.puts "Roles detected, aborting this seed."
  true ->
    Enum.each(roles, fn role ->
      Role.changeset(%Role{}, role)
      |> Repo.insert!
    end)
end

# Categories

categories = [
  %{
    name: "Arts",
    description: "You want to improve the arts."
  },
  %{
    name: "Economy",
    description: "You want to improve finance and the economic climate."
  },
  %{
    name: "Education",
    description: "You want to improve literacy, schools, and training."
  },
  %{
    name: "Environment",
    description: "You want to improve your environment."
  },
  %{
    name: "Government",
    description: "You want to improve government responsiveness."
  },
  %{
    name: "Health",
    description: "You want to improve prevention and treatment."
  },
  %{
    name: "Justice",
    description: "You want to improve your judicial system."
  },
  %{
    name: "Politics",
    description: "You want to improve elections and voting."
  },
  %{
    name: "Public Safety",
    description: "You want to improve crime prevention and safety."
  },
  %{
    name: "Science",
    description: "You want to improve tools for advancing science."
  },
  %{
    name: "Security",
    description: "You want to improve tools like encryption."
  },
  %{
    name: "Society",
    description: "You want to improve our communities."
  },
  %{
    name: "Technology",
    description: "You want to improve software tools and infrastructure."
  },
  %{
    name: "Transportation",
    description: "You want to improve how people travel."
  },
]

cond do
  Repo.all(Category) != [] ->
    IO.puts "Categories detected, aborting category seed."
  true ->
    Enum.each(categories, fn category ->
      Category.create_changeset(%Category{}, category)
      |> Repo.insert!
    end)
end

# Tasks

cond do
  Repo.all(Task) != [] ->
    IO.puts "Tasks detected, aborting this seed."
  true ->
    for i <- 1..50 do
      %Task{}
      |> Task.create_changeset(%{
        title: "test task #{i}",
        markdown: "test *body* #{i}",
        status: "open",
        number: i,
        project_id: 1,
        user_id: 1,
        task_list_id: Enum.random([1, 2, 3, 4])
      })
      |> Repo.insert!
    end
end

cond do
  Repo.all(ProjectCategory) != [] ->
    IO.puts "Project categories detected, aborting this seed."
  true ->
    %ProjectCategory{}
    |> ProjectCategory.create_changeset(%{
      project_id: 1,
      category_id: 12
    })
    |> Repo.insert!
end

cond do
  Repo.all(ProjectSkill) != [] ->
    IO.puts "Project skills detected, aborting this seed."
  true ->
    %ProjectSkill{}
    |> ProjectSkill.create_changeset(%{
      project_id: 1,
      skill_id: 1
    })
    |> Repo.insert!
end

cond do
  Repo.all(ProjectUser) != [] ->
    IO.puts "Project memberships detected, aborting this seed."
  true ->
    contributors = [
      %{
        project_id: 1,
        user_id: 1,
        role: "owner"
      },
      %{
        project_id: 1,
        user_id: 2,
        role: "admin"
      },
      %{
        project_id: 1,
        user_id: 3,
        role: "contributor"
      },
      %{
        project_id: 1,
        user_id: 4,
        role: "pending"
      }
    ]

    Enum.each(contributors, fn user ->
      membership =
        %ProjectUser{}
        |> ProjectUser.create_changeset(user)
        |> Repo.insert!

      membership
      |> ProjectUser.update_changeset(user)
      |> Repo.update!
    end)
end

cond do
  Repo.all(UserCategory) != [] ->
    IO.puts "User categories detected, aborting this seed."
  true ->
    user_categories = [
      %{
        category_id: 1,
        user_id: 1
      },
      %{
        category_id: 1,
        user_id: 2
      },
      %{
        category_id: 1,
        user_id: 3
      },
      %{
        category_id: 1,
        user_id: 4
      }
    ]

    Enum.each(user_categories, fn user_category ->
      %UserCategory{}
      |> UserCategory.create_changeset(user_category)
      |> Repo.insert!
    end)
end

cond do
  Repo.all(UserRole) != [] ->
    IO.puts "User roles detected, aborting this seed."
  true ->
    user_roles = [
      %{
        role_id: 1,
        user_id: 1
      },
      %{
        role_id: 1,
        user_id: 2
      },
      %{
        role_id: 1,
        user_id: 3
      },
      %{
        role_id: 1,
        user_id: 4
      }
    ]

    Enum.each(user_roles, fn user_role ->
      %UserRole{}
      |> UserRole.create_changeset(user_role)
      |> Repo.insert!
    end)
end

cond do
  Repo.all(UserSkill) != [] ->
    IO.puts "User skills detected, aborting this seed."
  true ->
    user_skills = [
      %{
        skill_id: 1,
        user_id: 1
      },
      %{
        skill_id: 1,
        user_id: 2
      },
      %{
        skill_id: 1,
        user_id: 3
      },
      %{
        skill_id: 1,
        user_id: 4
      }
    ]

    Enum.each(user_skills, fn user_skill ->
      %UserSkill{}
      |> UserSkill.create_changeset(user_skill)
      |> Repo.insert!
    end)
end
