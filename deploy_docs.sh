#!/bin/bash

# Ensure exit codes other than 0 fail the build
set -e

echo "Removing old local ./doc dir..."
rm -rf ./doc

# Pulling from GitHub
echo "Pulling from GitHub..."
mkdir -p doc
cd doc
git init
if ! git remote | grep origin; then
  git remote add origin git@github.com:code-corps/code-corps-api-github-pages.git
  git fetch
  git checkout gh-pages
fi
cd ..

# Generate docs
echo "Generating docs..."
mix docs

# Push to GitHub
echo "Pushing to GitHub..."
cd doc
git add .
git commit -m "Update docs"
git push -u origin gh-pages:gh-pages --force

# Exit successfully
exit 0
