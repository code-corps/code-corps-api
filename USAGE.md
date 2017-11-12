## Usage

- [How do I interact with the app?](#interacting-with-the-app)
- [How do I stop and start the server?](#stopping-and-starting-the-server)
- [How do I make requests to API endpoints?](#making-requests-to-api-endpoints)
- [How do I run tests?](#running-tests)
- [How do I view the API docs?](#api-docs)
- [How do I lint the code?](#linting-code-with-credo)
- [How do I serve the front-end?](#serving-ember)
- [How do I setup Github Integration?](#github-integration)
- [Do I need special environment variables?](#environment)

### Interacting with the app

You'll generally interact with the app using `mix` tasks. You can [read the Phoenix documentation here](http://www.phoenixframework.org/docs/mix-tasks).

### Stopping and starting the server

To start the server, run `mix phoenix.server`.

To stop the server, hit `Ctrl+C` twice.

### Making requests to API endpoints

You can make requests to `http://api.lvh.me:4000/YOUR_ENDPOINT` (`lvh.me` resolves itself and all subdomains to your `localhost` accordingly).

> Note: some browsers like Safari and Firefox may ask to download a file instead of displaying contents directly. This is a [known issue for JSON API](https://github.com/json-api/json-api/issues/1048) and if you find this inconvenient, please use Chrome or Opera. We recommend you use specialized tools for API development and discovery like [Postman](https://www.getpostman.com/) or [Paw](https://paw.cloud/).

### Running tests

To run the tests you run `MIX_ENV=test mix test`.

### API docs

You can [view the API documentation locally](docs/API.md) with the Apiary CLI.

The production API's documentation (matching the latest `master` branch) can be found online at `http://docs.codecorpsapi.apiary.io/`.

The staging API's documentation (matching the latest `develop` branch) can be found online at `http://docs.codecorpsapidevelop.apiary.io/`.

### Linting Code with Credo

[Credo](https://github.com/rrrene/credo) is a static code analysis tool for Elixir. In general, we conform to the [Credo Style Guide](https://github.com/rrrene/elixir-style-guide) when writing Elixir code. You can run `mix credo` to check your code for design, readability, and consistency against this guide.

Credo's style guide is influenced by this more popular and exhaustive community [Elixir Style Guide](https://github.com/levionessa/elixir_style_guide). We defer to that guide where the Credo guide is ambiguous, e.g. [external module references](https://github.com/levionessa/elixir_style_guide#modules).

### Serving Ember

The Code Corps API is intended to work alongside a client written in Ember. For that purpose, the Elixir application exposes all of its API endpoints behind an `api.` subdomain.

For Ember to work with your now running API listening on `localhost:4000`, you simply need to run under `ember serve` at `localhost:4200` and everything should work under normal conditions.

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
- `STRIPE_PLATFORM_CLIENT_ID` should be set to "Development `client_id`" key from the [Connect section of your Stripe dashboard](https://dashboard.stripe.com/account/applications/settings).

### Github Integration

To setup github integration follow instructions on this [wiki page]((https://github.com/code-corps/code-corps-api/wiki/GitHub-Apps-–-How-to-set-up-your-local-environment))