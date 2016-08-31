## How do I install the Code Corps API?

### Requirements

You will need to install [Docker](https://docs.docker.com/engine/installation/).

Here are some direct links if you're on [Mac OS X](https://docs.docker.com/docker-for-mac/) or [Windows](https://docs.docker.com/docker-for-windows/).

Follow those download instructions. Once you can run the `docker` command, you can safely move on.

### Clone this repository

You'll want to [clone this repository](https://help.github.com/articles/cloning-a-repository/) with `git clone https://github.com/code-corps/code-corps-phoenix.git`.

The directory structure will look like the following:

```shell
code-corps-phoenix/          # → Root folder for this project
├── blueprint/
├── config/
├── ...                  # → More standard Phoenix files
├── docker-compose.yml   # → Compose file for configuring Docker containers
└── Dockerfile           # → Creates base Ruby Docker container
```

### Setup your Docker containers and run the server

> Note: We bind to ports 49235 for `web`, 49236 for `test`, and 8081 for `apiary`. Make sure you're not running anything on those ports. We do not expose port 5432 for `postgres` or 9200 for `elasticsearch`.

Go to the `code-corps-phoenix` directory and copy the `.env.example` file:

```
cd code-corps-phoenix
cp .env.example
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

### Verify it worked

Point your browser (or make a direct request) to `http://api.localhost:49235/users`. You'll get the following response:

```json
{
  "jsonapi": {
    "version": "1.0"
  },
  "data": []
}
```

### Next steps

Now that you're set up, you should [read more about how to develop with the API](USAGE.md).

### Issues installing?

Having trouble?

Create an issue in this repo and we'll look into it.

Docker's a bit new for us, so there may be some hiccups at first. But hopefully this makes for a less painful developer environment for you in the long run.
