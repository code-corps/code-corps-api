FROM elixir:1.3.2

RUN apt-get update -qq && apt-get install -y build-essential

# PostgreSQL
RUN apt-get install -y libpq-dev

# Install hex
RUN mix local.hex --force

# Install rebar
RUN mix local.rebar --force

# Install the Phoenix framework itself
RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez

# Install NodeJS 6.x and the NPM
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install -y -q nodejs

# Set directory for our app
ENV APP_HOME /code-corps-api
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Copy code
ADD . $APP_HOME
