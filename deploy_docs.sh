#!/bin/bash

# Ensure exit codes other than 0 fail the build
set -e

# Generate docs
echo "Generating docs..."
mix docs

# Push to GitHub
echo "Pushing to GitHub..."
cd doc
git init
git add .
git commit -m "Update docs"
if ! git remote | grep origin; then
  git remote add origin git@github.com:code-corps/code-corps-api-github-pages.git
fi
git push -u origin master:gh-pages

# Exit successfully
exit 0
