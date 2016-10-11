alias CodeCorps.Repo
alias CodeCorps.Category
alias CodeCorps.Organization
alias CodeCorps.Project
alias CodeCorps.ProjectCategory
alias CodeCorps.ProjectSkill
alias CodeCorps.Role
alias CodeCorps.Skill
alias CodeCorps.Task
alias CodeCorps.User

# Users

users = [
  %{
    username: "adminstrator",
    email: "admin@example.org",
    password: "password",
    admin: true
  },
  %{
    username: "testuser",
    email: "test@example.com",
    password: "test123",
    admin: false
  },
]

cond do
  Repo.all(User) != [] ->
    IO.puts "Users detected, aborting user seed."
  true ->
    Enum.each(users, fn user ->
      %User{}
      |> User.registration_changeset(user)
      |> Repo.insert!
    end)
end

# Organizations

organizations = [
  %{
    name: "Code Corps",
    description: "Help build and fund public software projects for social good"
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
    organization_id: 1
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
        task_type: Enum.random(~w{idea issue task}),
        status: "open",
        number: i,
        project_id: 1,
        user_id: 1
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
