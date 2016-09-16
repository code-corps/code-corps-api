### Stopping and starting the server

Need to stop the containers? Either `Ctrl+C` or in a separate prompt run `docker-compose stop`.

To start the services again you can run `docker-compose up`, or `docker-compose start` to start the containers in a detached state.

### Running tests

To run the tests you can run `docker-compose run test mix test`.

### Rebuilding Docker containers

If you ever need to rebuild you can run `docker-compose up --build`. Unless you've destroyed your Docker container images, this should be faster than the first run.


### Pushing changes

You can use `git` as you normally would, either on your own host machine or in Docker's `web` container.
