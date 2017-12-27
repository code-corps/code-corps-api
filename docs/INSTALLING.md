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

This file places environment variables on separate lines, prepended with `export` to make them available to your Elixir application. You can [read about environment variables you may want here](../USAGE.md#environment).

> Note: Depending on your PostgreSQL configuration, you may also want to add lines for `DATABASE_POSTGRESQL_USERNAME`, `DATABASE_POSTGRESQL_PASSWORD`, `DATABASE_POSTGRESQL_HOST`.
>
> Your `dev.exs` has some sane defaults of `postgres`, `postgres`, and `localhost`, respectively.

> You might want to add `GITHUB_TEST_APP_PEM` to your .env in order test suit to pass locally
> 1. Generate rsa private key (or get one from here http://phpseclib.sourceforge.net/rsa/examples.html)
> 2. base64 encode this key (f.e. in `iex> Base.encode64(your_private_rsa_key`))

Now, you can source the `.env`:

```shell
source .env
```

You can now fetch your dependencies, compile, and run the server:

```shell
mix deps.get
```

You'll likely need to create the database, using [Ecto's `create` mix task](https://hexdocs.pm/ecto/Mix.Tasks.Ecto.Create.html):

```shell
mix ecto.create
```

> Note: If you're seeing error output like `psql: FATAL: role "postgres" does not exist`, you'll need to create the `"postgres"` role by running `psql` in your CLI, followed by `CREATE USER postgres SUPERUSER;`. Please post an issue if you're having other issues.

You can now compile and run the server:

```shell
mix phx.server
```

You can also run your app inside IEx (Interactive Elixir) as:

```shell
iex -S mix phoenix.server
```

If you have a different version of Elixir installed than what is specified in [`mix.exs`](https://github.com/code-corps/code-corps-api/blob/develop/mix.exs), then you may want to use a version manager such as [Kiex](https://github.com/taylor/kiex) to switch between different versions.

### Seed the database

You'll probably want to seed the database. You can do this with the following command:

```shell
mix ecto.setup
```

This is an alias that runs `ecto.create`, `ecto.migrate`, and `run priv/repo/seeds.exs` in succession.

You can open the file [`priv/repo/seeds.exs`](/priv/repo/seeds.exs) to see what data was seeded into your database.

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
