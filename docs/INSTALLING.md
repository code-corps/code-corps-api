## How do I install the Code Corps API?

### Requirements

You will need to install [Docker](https://docs.docker.com/engine/installation/).

Here are some direct links if you're on [Mac OS X](https://docs.docker.com/docker-for-mac/) or [Windows](https://docs.docker.com/docker-for-windows/).

Follow those download instructions. Once you can run the `docker` command, you can safely move on.

>Note: If you are using Docker in Windows, it is recommended you use PowerShell. If you run into permission issues, try running Docker from PowerShell as an Admin.

### Clone this repository

You'll want to [clone this repository](https://help.github.com/articles/cloning-a-repository/) with `git clone https://github.com/code-corps/code-corps-api.git`. If you plan on contributing, you'll want to fork it too!


The directory structure will look like the following:

```shell
code-corps-api/          # → Root folder for this project
├── blueprint/
├── config/
├── ...                  # → More standard Phoenix files
├── docker-compose.yml   # → Compose file for configuring Docker containers
└── Dockerfile           # → Creates base Elixir Docker container
```

### Setup your Docker containers and run the server

> Note: We bind to ports 49235 for `web`, 49236 for `test`, and 8081 for `apiary`. Make sure you're not running anything on those ports. We do not expose port 5432 for `postgres` or 9200 for `elasticsearch`.

Go to the `code-corps-api` directory and copy the `.env.example` file:

```
cd code-corps-api
cp .env.example .env
```

Now, you can initialize docker, type:

```shell
docker-compose build
docker-compose up
```

You should now see a lot of output from the Docker processes and will not be able to interact with that terminal window.

Docker will set up your base Elixir container, as well as containers for:

- `postgres`
- `elasticsearch`
- `web` runs `mix do ecto.create, ecto.migrate, phoenix.server`
- `test` runs `mix test`
- `apiary` runs an [Apiary client](https://github.com/apiaryio/apiary-client) server on port `8081`

You can view more detailed information about these services in the `docker-compose.yml` file, but you shouldn't need to edit it unless you're intentionally contributing changes to our Docker workflow.

#### Troubleshooting
If you see an error like this at the bottom of the output:

```shell
Unchecked dependencies for environment dev:
* httpoison (Hex package)
  lock mismatch: the dependency is out of date (run "mix deps.get" to fetch locked version)
** (Mix) Can't continue due to errors on dependencies
```

It means you need to fetch your dependencies:
```shell
docker-compose run web mix deps.get
```

Then re-run the previous command:
```shell
docker-compose build
docker-compose up
```

### Seed the database

You'll probably want to seed the database. You can do this with the following command:

```shell
docker-compose run web mix run priv/repo/seeds.exs
```

### Verify it worked

Point your browser (or make a direct request) to `http://api.lvh.me:49235/users` (`lvh.me` resolves itself and all subdomains to your `localhost` accordingly). You'll get the following response (although you might have data if you seeded the database):

```json
{
  "jsonapi": {
    "version": "1.0"
  },
  "data": []
}
```

Note: some browsers like Safari and Firefox may ask to download a file instead of displaying its contents directly. This is a [known issue for JSON API](https://github.com/json-api/json-api/issues/1048) and if you find this inconvenient, please use Chrome or Opera. We recommend to use specialised tools for API development and discovery like [Postman](https://www.getpostman.com/) or [Paw](https://paw.cloud/).

### Next steps

Now that you're set up, you should [read more about how to develop with the API](USAGE.md).

### Issues installing?

Having trouble?

Create an issue in this repo and we'll look into it.

Docker's a bit new for us, so there may be some hiccups at first. But hopefully this makes for a less painful developer environment for you in the long run.
