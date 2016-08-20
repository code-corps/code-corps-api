alias CodeCorps.Repo
alias CodeCorps.Category
alias CodeCorps.Organization
alias CodeCorps.Project
alias CodeCorps.Skill
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
    email: "test@example.org",
    password: "test",
    admin: false
  },
]

cond do
  Repo.all(User) != [] ->
    IO.puts "Users detected, aborting user seed."
  true ->
    Enum.each(users, fn user ->
      User.registration_changeset(%User{}, user)
      |> Repo.insert!
    end)
end

# Organizations

organizations = [
  %{
    name: "Code Corps"
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
      Project.changeset(%Project{}, project)
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
