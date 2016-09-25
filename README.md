# Code Corps Phoenix API

![Code Corps Phoenix Logo](https://d3pgew4wbk2vb1.cloudfront.net/images/github/code-corps-api.png)

[![CircleCI](https://circleci.com/gh/code-corps/code-corps-api.svg?style=svg)](https://circleci.com/gh/code-corps/code-corps-api) [![Inline docs](http://inch-ci.org/github/code-corps/code-corps-api.svg?branch=develop)](http://inch-ci.org/github/code-corps/code-corps-api) [![Coverage Status](https://coveralls.io/repos/github/code-corps/code-corps-api/badge.svg?branch=develop)](https://coveralls.io/github/code-corps/code-corps-api?branch=develop) [![Deps Status](https://beta.hexfaktor.org/badge/all/github/code-corps/code-corps-api.svg)](https://beta.hexfaktor.org/github/code-corps/code-corps-api) [![Slack Status](http://slack.codecorps.org/badge.svg)](http://slack.codecorps.org)

## Installing with Docker

To make your life easier, you can just clone this repository and use our Docker container. [Follow this guide to get started.](docs/INSTALLING.md)

## Continuous Integration

We use [CircleCI](https://circleci.com/) to test your branches and continuously deploy branches merged into `develop` to our staging API and branches merged into `master` to our production API.

If your test fails on Circle, you should re-check your tests. Sometimes this indicates a mismatch between your environment and our expected environment.

The `circle.yml` file specifies what happens in the builds. You can [read more about that in Circle's documentation](https://circleci.com/docs/configuration/).

The CircleCI builds also rely on some environment variables for reporting, deployments, and other requirements.

## Usage

To learn about how to run the application, run tests, configure your environment, and more [in the usage guides](docs/USAGE.md).
