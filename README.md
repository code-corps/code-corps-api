# Code Corps Phoenix API

![Code Corps Phoenix Logo](https://d3pgew4wbk2vb1.cloudfront.net/images/github/code-corps-api.png)

[![CircleCI](https://circleci.com/gh/code-corps/code-corps-api.svg?style=svg)](https://circleci.com/gh/code-corps/code-corps-api) [![Coverage Status](https://coveralls.io/repos/github/code-corps/code-corps-api/badge.svg?branch=develop)](https://coveralls.io/github/code-corps/code-corps-api?branch=develop) [![Deps Status](https://beta.hexfaktor.org/badge/all/github/code-corps/code-corps-api.svg)](https://beta.hexfaktor.org/github/code-corps/code-corps-api)

## Installing with Docker

To make your life easier, you can just clone this repository and use our Docker container. [Follow this guide to get started.](docs/INSTALLING.md)

## Continuous Integration

We use [CircleCI](https://circleci.com/) to test your branches and continuously deploy branches merged into `develop` to our staging API and branches merged into `master` to our production API.

If your test fails on Circle, you should re-check your tests. Sometimes this indicates a mismatch between your environment and our expected environment.

The `circle.yml` file specifies what happens in the builds. You can [read more about that in Circle's documentation](https://circleci.com/docs/configuration/).

The CircleCI builds also rely on some environment variables for reporting, deployments, and other requirements.

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
