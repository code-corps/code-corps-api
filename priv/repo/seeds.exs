alias CodeCorps.Repo
alias CodeCorps.Category
alias CodeCorps.Role

roles = [
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
    name: "Tester",
    ability: "Testing",
    kind: "technology",
  },
  %{
    name: "Designer",
    ability: "Design",
    kind: "creative",
  },
  %{
    name: "Marketer",
    ability: "Marketing",
    kind: "creative",
  },
  %{
    name: "Photographer",
    ability: "Photography",
    kind: "creative",
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
    name: "Lawyer",
    ability: "Legal",
    kind: "support",
  },
  %{
    name: "Researcher",
    ability: "Research",
    kind: "support",
  },
]

cond do
  Repo.all(Role) != [] ->
    IO.puts "Roles detected, aborting role seed."
  true ->
    Enum.each(roles, fn role ->
      Role.changeset(%Role{}, role)
      |> Repo.insert!
    end)
end

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
