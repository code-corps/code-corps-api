### Stopping and starting the server

Need to stop the containers? Either `Ctrl+C` or in a separate prompt run `docker-compose stop`.

To start the services again you can run `docker-compose up`, or `docker-compose start` to start the containers in a detached state.

### Running tests

To run the tests you can run `docker-compose run test mix test`.

### Rebuilding Docker containers

If you ever need to rebuild you can run `docker-compose up --build`. Unless you've destroyed your Docker container images, this should be faster than the first run.

### Donations and Stripe

If you're testing anything with donations locally, you'll need a Stripe account. Unfortunately, we cannot provide you with sandboxed keys for doing this on your own.

You can register for a Stripe account here: [https://dashboard.stripe.com/register](https://dashboard.stripe.com/register)

In your `.env` you should have a `STRIPE_SECRET_KEY` and `STRIPE_PLATFORM_CLIENT_ID`.

- `STRIPE_SECRET_KEY` should be set to your "Test Secret Key" from the [API Keys section of your Stripe dashboard](https://dashboard.stripe.com/account/apikeys).
- `STRIPE_PLATFORM_CLIENT_ID` should be set to "Development `client_id`" key from the [Connect section of your Stripe dashboard](https://dashboard.stripe.com/account/applications/settings). You'll want to set the redirect URI to `http://localhost:4200/oauth/stripe`.

### Pushing changes

You can use `git` as you normally would, either on your own host machine or in Docker's `web` container.
