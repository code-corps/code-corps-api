## How do I install the Code Corps API?

### Requirements

You will need to install the following:

- [Elixir](http://elixir-lang.org/install.html)
- [PostgreSQL](https://www.postgresql.org/download/)

### Clone this repository

You'll want to [clone this repository](https://help.github.com/articles/cloning-a-repository/) with `git clone https://github.com/code-corps/code-corps-api.git`. If you plan on contributing, you'll want to fork it too!


The directory structure will look like the following:

```shell
code-corps-api/          # → Root folder for this project
├── bin/
├── blueprint/
├── config/
├── docs/
└── ...                  # → More standard Phoenix files
```

Go to the `code-corps-api` directory and copy the `.env.example` file:

```
cd code-corps-api
cp .env.example .env
```

Now, you can source the `.env`:

```shell
source .env
```

You can now fetch your dependencies, compile, and run the server:

```shell
mix deps.get
mix phoenix.server
```

You can also run your app inside IEx (Interactive Elixir) as:

```shell
iex -S mix phoenix.server
```

### Seed the database

You'll probably want to seed the database. You can do this with the following command:

```shell
mix ecto.setup
```

This is an alias that runs `ecto.create`, `ecto.migrate`, and `run priv/repo/seeds.exs` in succession.

### Verify it worked

Point your browser (or make a direct request) to `http://api.lvh.me:4000/users` (`lvh.me` resolves itself and all subdomains to your `localhost` accordingly). You'll get the following response (although you might have data if you seeded the database):

```json
{
  "jsonapi": {
    "version": "1.0"
  },
  "data": []
}
```

> Note: some browsers like Safari and Firefox may ask to download a file instead of displaying its contents directly. This is a [known issue for JSON API](https://github.com/json-api/json-api/issues/1048) and if you find this inconvenient, please use Chrome or Opera. We recommend to use specialized tools for API development and discovery like [Postman](https://www.getpostman.com/) or [Paw](https://paw.cloud/).

### Next steps

Now that you're set up, you should [read more about how to develop with the API](../USAGE.md).

### Issues installing?

Having trouble?

Create an issue in this repo and we'll look into it.
