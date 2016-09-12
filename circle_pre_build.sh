#!/bin/bash

# Ensure exit codes other than 0 fail the build
set -e

# Check for asdf
if ! asdf | grep version; then
  # Install asdf into ~/.asdf if not previously installed
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.1.0
fi

# Add plugins (Erlang and Elixir) for asdf

# Check to see if asdf's Erlang plugin is installed
if ! asdf plugin-list | grep erlang; then
  # Install the Erlang plugin
  asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git
else
  # Update the Erlang plugin
  asdf plugin-update erlang
fi

# Check to see if asdf's Elixir plugin is installed
if ! asdf plugin-list | grep elixir; then
  # Install the Elixir plugin
  asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
else
  # Update the Elixir plugin
  asdf plugin-update elixir
fi

# Extract versions from elixir_buildpack.config into variables
. elixir_buildpack.config

# Write .tool-versions for asdf
echo "erlang $erlang_version" >> .tool-versions
echo "elixir $elixir_version" >> .tool-versions

# Install erlang/elixir
echo "Installing Erlang..."
asdf install erlang $erlang_version

echo "Installing Elixir..."
asdf install elixir $elixir_version

# Get dependencies
yes | mix deps.get
yes | mix local.rebar

# Exit successfully
exit 0
