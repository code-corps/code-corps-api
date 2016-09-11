FROM elixir:1.3.2

RUN apt-get update -qq && apt-get install -y build-essential

RUN apt-get install -y -q apt-utils

RUN apt-get install -y -q inotify-tools

# PostgreSQL
RUN apt-get install -y libpq-dev

# Install hex
RUN mix local.hex --force

# Install rebar
RUN mix local.rebar --force

# Install the Phoenix framework itself
RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez

# Set directory for our app
ENV APP_HOME /code-corps-api
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Copy code
ADD . $APP_HOME
