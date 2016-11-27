## Usage

- [How do I interact with the app?](#interacting-with-the-app)
- [How do I stop and start the server?](#stopping-and-starting-the-server)
- [How do I run tests?](#running-tests)
- [How do I rebuild Docker containers?](#rebuilding-docker-containers)
- [How do I serve the front-end?](#serving-ember)
- [Do I need special environment variables?](#environment)
- [How do I push changes to GitHub?](#pushing-changes)

### Interacting with the app

You'll generally interact with the app using `docker-compose`. You can choose not to if you're contributing often enough to not need to worry about dependency management. But if you're short on time, Docker is probably the happier path to get up and running quickly.

Here are conversions of your typical Elixir project commands:

- `iex -S mix phoenix.server` → `docker-compose run web iex -S mix phoenix.server`
- `mix run priv/repo/seeds.exs` → `docker-compose run web mix run priv/repo/seeds/.exs`
- `mix test` → `docker-compose run test mix test`
- and so on...

These follow the basic format of `my-command with arguments` → `docker-compose run TARGET_CONTAINER my-command with arguments`.

### Stopping and starting the server

Need to stop the containers? Either `Ctrl+C` or in a separate prompt run `docker-compose stop`.

To start the services again you can run `docker-compose up`, or `docker-compose start` to start the containers in a detached state.

### Rebuilding Docker containers

If you ever need to rebuild you can run `docker-compose up --build`. Unless you've destroyed your Docker container images, this should be faster than the first run.

### Running tests

To run the tests you can run `docker-compose run test mix test`.

### Linting Code with Credo

[Credo](https://github.com/rrrene/credo) is a static code analysis tool for Elixir. In general, we conform to the [Credo Style Guide](https://github.com/rrrene/elixir-style-guide) when writing Elixir code. You can run `mix credo` to check your code for design, readability, and consistency against this guide.

Credo's style guide is influenced by this more popular and exhaustive community [Elixir Style Guide](https://github.com/levionessa/elixir_style_guide). We defer to that guide where the Credo guide is ambiguous, e.g. [external module references](https://github.com/levionessa/elixir_style_guide#modules).

### Serving Ember

The Code Corps API is intended to work alongside a client written in Ember. For that purpose, the Elixir application exposes all of its API endpoints behind an `api.` subdomain.

For Ember to work with your now running API listening on `localhost:49235`, you simply need to run under `ember serve` at `localhost:4200` and everything should work under normal conditions.

### Environment

When contributing to the app, you will not have access to secure environment variables required to run some tests or work on aspects of the app locally. Unfortunately, for security reasons, we cannot provide you with sandboxed keys for doing this on your own.

You can see these variables in `.env.example`.

Without too much effort, you should be able to set up keys on your own for the following portions of the app:

- [Images and AWS](#images-and-aws)
- [Donations and Stripe](#donations-and-stripe)

#### Images and AWS

If you're trying to upload and serve images like user, project, or organization icons, then we recommend you sign up for an AWS account.

In your `.env` you'll need the following:

- `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are your credentials, typically generated from AWS IAM (identity management)
- `CLOUDFRONT_DOMAIN` should be the domain name of your CloudFront instance that sits in front of your S3 bucket
- `S3_BUCKET` should be the bucket you'll be uploading files to

#### Donations and Stripe

If you're testing anything with donations locally, you'll need a Stripe account.

You can register for a Stripe account here: [https://dashboard.stripe.com/register](https://dashboard.stripe.com/register)

In your `.env` you should have a `STRIPE_SECRET_KEY` and `STRIPE_PLATFORM_CLIENT_ID`.

- `STRIPE_SECRET_KEY` should be set to your "Test Secret Key" from the [API Keys section of your Stripe dashboard](https://dashboard.stripe.com/account/apikeys).
- `STRIPE_PLATFORM_CLIENT_ID` should be set to "Development `client_id`" key from the [Connect section of your Stripe dashboard](https://dashboard.stripe.com/account/applications/settings). You'll want to set the redirect URI to `http://localhost:4200/oauth/stripe`.

### Pushing changes

You can use `git` as you normally would, either on your own host machine or in Docker's `web` container.
