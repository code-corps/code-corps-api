alias CodeCorps.{
  Category, Organization, ProjectUser, Project, ProjectCategory, ProjectSkill,
  Repo, Role, Skill, Task, User, UserCategory, UserRole, UserSkill
}

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

case Repo.all(User) do
  [] ->
    users
    |> Enum.map(fn params ->
      registration_changeset = User.registration_changeset(%User{}, params)
      update_changeset = User.update_changeset(%User{}, params)

      registration_changeset
      |> Ecto.Changeset.merge(update_changeset)
      |> Repo.insert!()
    end)
  _ -> IO.puts "Users detected, aborting user seed."
end

organizations = [
  %{
    name: "Code Corps",
    description: "Help build and fund public software projects for social good",
    owner_id: 1
  },
]

case Repo.all(Organization) do
  [] ->
    organizations
    |> Enum.each(fn params ->
      %Organization{}
      |> Organization.create_changeset(params)
      |> Repo.insert!()
    end)
  _ -> IO.puts "Organizations detected, aborting organization seed."
end

projects = [
  %{
    description: "A basic project for use in development",
    long_description_markdown: "A basic project for use in `development`",
    title: "Code Corps",
    organization_id: 1
  }
]

case Repo.all(Project) do
  [] ->
    projects
    |> Enum.each(fn params ->
      %Project{}
      |> Project.create_changeset(params)
      |> Ecto.Changeset.put_change(:approved, true)
      |> Repo.insert!()
    end)
  _ -> IO.puts "Projects detected, aborting project seed."
end

project_users = [
  %ProjectUser{project_id: 1, user_id: 1, role: "owner"},
  %ProjectUser{project_id: 1, user_id: 2, role: "admin"},
  %ProjectUser{project_id: 1, user_id: 3, role: "contributor"},
  %ProjectUser{project_id: 1, user_id: 4, role: "pending"}
]

case Repo.all(ProjectUser) do
  [] -> Enum.each(project_users, &Repo.insert!/1)
  _ -> IO.puts "Project users detected, aborting this seed."
end

skills = [
  %Skill{title: "CSS"},
  %Skill{title: "Docker"},
  %Skill{title: "Ember.js"},
  %Skill{title: "HTML"},
  %Skill{title: "Ruby"},
  %Skill{title: "Ruby on Rails"}
]

case Repo.all(Skill) do
  [] -> Enum.each(skills, &Repo.insert!/1)
  _ -> IO.puts "Skills detected, aborting skill seed."
end

roles = [
  %Role{name: "Accountant", ability: "Accounting", kind: "support"},
  %Role{name: "Administrator", ability: "Administrative", kind: "support"},
  %Role{name: "Donor", ability: "Donations", kind: "support"},
  %Role{name: "Backend Developer", ability: "Backend Development", kind: "technology"},
  %Role{name: "Data Scientist", ability: "Data Science", kind: "technology"},
  %Role{name: "Designer", ability: "Design", kind: "creative"},
  %Role{name: "DevOps", ability: "DevOps", kind: "technology"},
  %Role{name: "Front End Developer", ability: "Front End Development", kind: "technology"},
  %Role{name: "Lawyer", ability: "Legal", kind: "support"},
  %Role{name: "Marketer", ability: "Marketing", kind: "creative"},
  %Role{name: "Mobile Developer", ability: "Mobile Development", kind: "technology"},
  %Role{name: "Product Manager", ability: "Product Management", kind: "technology"},
  %Role{name: "Photographer", ability: "Photography", kind: "creative"},
  %Role{name: "Researcher", ability: "Research", kind: "support"},
  %Role{name: "Tester", ability: "Testing", kind: "technology"},
  %Role{name: "Video Producer", ability: "Video Production", kind: "creative"},
  %Role{name: "Writer", ability: "Writing", kind: "creative"},
]

case Repo.all(Role) do
  [] -> Enum.each(roles, &Repo.insert!/1)
  _ -> IO.puts "Roles detected, aborting this seed."
end

categories = [
  %Category{
    name: "Arts",
    description: "You want to improve the arts.",
    slug: "arts"
  },
  %Category{
    name: "Economy",
    description: "You want to improve finance and the economic climate.",
    slug: "economy"
  },
  %Category{
    name: "Education",
    description: "You want to improve literacy, schools, and training.",
    slug: "education"
  },
  %Category{
    name: "Environment",
    description: "You want to improve your environment.",
    slug: "environment"
  },
  %Category{
    name: "Government",
    description: "You want to improve government responsiveness.",
    slug: "government"
  },
  %Category{
    name: "Health",
    description: "You want to improve prevention and treatment.",
    slug: "health"
  },
  %Category{
    name: "Justice",
    description: "You want to improve your judicial system.",
    slug: "justice"
  },
  %Category{
    name: "Politics",
    description: "You want to improve elections and voting.",
    slug: "politics"
  },
  %Category{
    name: "Public Safety",
    description: "You want to improve crime prevention and safety.",
    slug: "public-safety"
  },
  %Category{
    name: "Science",
    description: "You want to improve tools for advancing science.",
    slug: "science"
  },
  %Category{
    name: "Security",
    description: "You want to improve tools like encryption.",
    slug: "security"
  },
  %Category{
    name: "Society",
    description: "You want to improve our communities.",
    slug: "society"
  },
  %Category{
    name: "Technology",
    description: "You want to improve software tools and infrastructure.",
    slug: "technology"
  },
  %Category{
    name: "Transportation",
    description: "You want to improve how people travel.",
    slug: "transportation"
  },
]

case Repo.all(Category) do
  [] -> Enum.each(categories, &Repo.insert!/1)
  _ -> IO.puts "Categories detected, aborting category seed."
end

# Tasks

case Repo.all(Task) do
  [] ->
    for i <- 1..50 do
      markdown = "test *body* #{i}"
      options = %Earmark.Options{code_class_prefix: "language-"}
      html = Earmark.as_html!(markdown, options)

      task = %Task{
        title: "test task #{i}",
        markdown: markdown,
        body: html,
        status: "open",
        number: i,
        project_id: 1,
        user_id: 1,
        task_list_id: Enum.random([1, 2, 3, 4])
      }

      task |> Repo.insert!
    end
  _ -> IO.puts "Tasks detected, aborting this seed."
end

project_categories = [
  %ProjectCategory{project_id: 1, category_id: 12}
]

case Repo.all(ProjectCategory) do
  [] -> Enum.each(project_categories, &Repo.insert!/1)
  _ -> IO.puts "Project categories detected, aborting this seed."
end

project_skills = [
  %ProjectSkill{project_id: 1, skill_id: 1}
]

case Repo.all(ProjectSkill) do
  [] -> Enum.each(project_skills, &Repo.insert!/1)
  _ -> IO.puts "Project skills detected, aborting this seed."
end

user_categories = [
  %UserCategory{category_id: 1, user_id: 1},
  %UserCategory{category_id: 1, user_id: 2},
  %UserCategory{category_id: 1, user_id: 3},
  %UserCategory{category_id: 1, user_id: 4}
]

case Repo.all(UserCategory) do
  [] -> Enum.each(user_categories, &Repo.insert!/1)
  _ -> IO.puts "User categories detected, aborting this seed."
end

user_roles = [
  %UserRole{role_id: 1, user_id: 1},
  %UserRole{role_id: 1, user_id: 2},
  %UserRole{role_id: 1, user_id: 3},
  %UserRole{role_id: 1, user_id: 4}
]

case Repo.all(UserRole) do
  [] -> Enum.each(user_roles, &Repo.insert!/1)
  _ -> IO.puts "User roles detected, aborting this seed."
end

user_skills = [
  %UserSkill{skill_id: 1, user_id: 1},
  %UserSkill{skill_id: 1, user_id: 2},
  %UserSkill{skill_id: 1, user_id: 3},
  %UserSkill{skill_id: 1, user_id: 4}
]

case Repo.all(UserSkill) do
  [] -> Enum.each(user_skills, &Repo.insert!/1)
  _ -> IO.puts "User skills detected, aborting this seed."
end
