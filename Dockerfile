FROM elixir:1.3.4
ENV APP_HOME /code-corps-api
RUN mkdir $APP_HOME

RUN apt-get update -qq && apt-get install -y build-essential

RUN apt-get install -y -q apt-utils

RUN apt-get install -y -q inotify-tools

# PostgreSQL
RUN apt-get install -y libpq-dev

# Install the Phoenix framework itself
RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez

# Set directory for our app
WORKDIR $APP_HOME
COPY mix.exs mix.lock $APP_HOME/

# Install hex
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.clean --all && \
    mix deps.get

# Copy code
ADD . $APP_HOME
