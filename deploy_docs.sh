#!/bin/bash

# Ensure exit codes other than 0 fail the build
set -e

# Pulling from GitHub
echo "Pulling from GitHub..."
mkdir -p doc
cd doc
git init
if ! git remote | grep origin; then
  git remote add origin git@github.com:code-corps/code-corps-api-github-pages.git
  git pull
fi
cd ..

# Generate docs
echo "Generating docs..."
mix docs
cd doc

# Push to GitHub
echo "Pushing to GitHub..."
git add .
git commit -m "Update docs"
git push -u origin master:gh-pages

# Exit successfully
exit 0
