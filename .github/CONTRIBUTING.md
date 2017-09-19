# Contributing

Thanks for thinking about helping! How would you like to help?

- [I want to build a new feature.](#how-to-tackle-a-new-feature)
- [I want to improve the documentation.](#what-kind-of-documentation-are-you-writing)
- [I want to fix a bug.](#how-to-fix-a-bug)
- [I want to refactor some code.](#how-to-refactor-some-code)
- [I don't know how to help.](#what-if-i-dont-know-how-to-help)

## Before you get started

1. [Fork the repo](https://help.github.com/articles/fork-a-repo/).

2. Read and work through [the installation guide](/docs/INSTALLING.md).

3. Run the tests. We only take pull requests with passing tests, and it's great to know that you have a clean slate: `MIX_ENV=test mix test`

Okay, you're ready to go!

## How to tackle a new feature

If there's already an issue for the feature you want to tackle, how complete is the description? Do you know what to do next? Are you confident you know what "done" looks like?

If there's not an issue yet, write one.

Whether you're writing a new issue or improving on an existing issue, be sure to clarify exactly how you expect the finished change to look and work.

One of the best ways to write a feature is in user story format:

> As an [actor], I want to do [action], so that [benefit].

For example, let's say we wanted to write some Slack integration for new comments posted to a Code Corps project. That user story might look something like:

> As a project maintainer, I want to see new comments on my project task in my Slack channel so that everyone can see and react to some of the latest changes in the project.

You may want to go deeper into detail. Posting screenshots of designs or expected test cases and scenarios are even more helpful. Place yourself in the shoes of the person who's going to accomplish the task – even if that person is you. What steps should I be taking next to finish this task?

Once you've created the issue, you can [make your changes and push them up](#how-to-write-new-code).

## What kind of documentation are you writing?

- [I want to improve the documentation of the API endpoints.](#improving-the-api-endpoint-docs)
- [I want to document some of the internals of the Elixir app](#improving-elixir-docs).
- [I want to improve the docs on GitHub.](#improving-the-readme)

## Improving the API endpoint docs

We're using [API Blueprint](https://apiblueprint.org/) for writing our docs, and you can use the Apiary CLI tool to preview them.

#### Learning how to write API Blueprint documentation

API Blueprint has a [quick tutorial you can read](https://apiblueprint.org/documentation/tutorial.html) that walks through writing your first docs in the API Blueprint language.

You can [read more examples here](https://github.com/apiaryio/api-blueprint/tree/master/examples) or check our own blueprint for examples.

#### Where do I make changes?

You will be working with the `blueprint/api.apib` document. You'll likely be adding any number of:

- Resource Groups
- Resources
- Actions
- URI Templates
- URI Parameters
- Data Structures

Data Structures often serve as your base objects for assembling the higher-level endpoint documentation. These objects are composeable – like Lego blocks – in new and often interesting ways.

The `/users/:id` endpoint documented in the `User` resource group, for example, may contain a `User Response` for its `200` response. This `User Response` data structure is itself composed of a `User` data structure (which collects the attributes for that user like `email` and `username`) and a `User Relationships Base` data structure, which includes yet more data structures like the `User Skills Relationship`.

By creating small, modular pieces, we can assemble complex data structures that describe our API.

#### Previewing your changes

You can preview your changes by [walking through our guide on how to generate API documentation locally](/docs/API.md).

[Done with your changes?](#i-finished-my-changes)

## Improving Elixir docs

You can see how much code is documented on [Inch CI](http://inch-ci.org/github/code-corps/code-corps-api).

You can learn about how to write documentation for Elixir apps from these places:

- [Elixir School has a great guide](https://elixirschool.com/lessons/basics/documentation/)
- [Elixir itself also has a great guide](http://elixir-lang.org/docs/stable/elixir/writing-documentation.html)
- And Elixir has [a deeper guide for Module documentation specifically](http://elixir-lang.org/docs/stable/elixir/Module.html)

[Done with your changes?](#i-finished-my-changes)

## Improving the README

If you're just looking to improve the README, there's a couple things you should know:

- Open an issue first. It's better if we discuss your proposed changes.
- We try to keep the main `README.md` lightweight and use it as a jumping point to other docs.
- Most other docs can be placed in `/docs`.
- Try to make it easy for people to jump around in your doc.

[Done with your changes?](#i-finished-my-changes)

## How to fix a bug

If you're fixing a bug that's already been added to the issues, ask yourself whether the bug description is clear. Do you know what circumstances led to the bug? Does it seem easy to reproduce?

If you've spotted a bug yourself, open an issue and try to answer those questions.

Then start writing some code:

1. Make the tests fail.

  Identify what's happening in the bug with a test. This way the bug is reproducible for everyone else in the project, and we won't regress into making the bug ever again (hopefully!).

2. Make the tests pass again.

  Write your code that fixes the bug and makes it pass.

[Done with your changes?](#i-finished-my-changes)

## How to refactor some code

Refactoring code shouldn't require any new tests, but you should [make sure the tests still pass](#running-tests).

[Done with your refactoring?](#i-finished-my-changes)

## How to write new code

When you're ready to write some new code, you should do the following:

1. Write some documentation for your change.

  Why do this first? Well, if you know the behavior you want to see, then it's easier to validate if it works as expected. Think of this as documentation-driven development.

  [What kind of documentation are you writing?](#what-kind-of-documentation-are-you-writing)

2. Add a test for your change. [Here's how to run tests.](#running-tests)

3. Make the test pass.

Try to keep your changes to a max of around 200 lines of code whenever possible. Why do this? Apparently the more changes incurred in a pull request, the likelier it is that people who review your code will just gloss over the details. Smaller pull requests get more comments and feedback than larger ones. Crazy, right?

[Done with your changes and ready for a review?](#i-finished-my-changes)

## What if I don't know how to help?

Not a problem! You can try looking around for issues that say `good for new contributors`. Documentation really is a good place to start. If you're still not sure, just [join our Slack](http://slack.codecorps.org) and flag someone down. Someone can help point you in the right direction.

## I finished my changes

Now you just need to push your finished code to your fork and submit a pull request.

Your pull request will be run through a continuous integration server to test your changes, [as described here](#continuous-integration).

At this point you're waiting on us. We like to at least comment on, if not
accept, pull requests within a week's time. We may suggest some changes or improvements or alternatives.

Some things that will increase the chance that your pull request is accepted:

* Use Elixir idioms
* Include tests that fail without your code, and pass with it
* Update the documentation, the surrounding one, examples elsewhere, guides,
  whatever is affected by your contribution

Has your code been reviewed? [Here's what we need before we can merge.](#before-we-can-merge)

## Continuous Integration

We use [CircleCI](https://circleci.com/) to test your branches and continuously deploy branches merged into `develop` to our staging API and branches merged into `master` to our production API.

If your test fails on Circle, you should re-check your tests. Sometimes this indicates a mismatch between your environment and our expected environment.

The `circle.yml` file specifies what happens in the builds. You can [read more about that in Circle's documentation](https://circleci.com/docs/configuration/).

The CircleCI builds also rely on some environment variables for reporting, deployments, and other requirements.

## Before We Can Merge

If you've had a pull request reviewed and accepted, congratulations! Before we can merge your changes, we'll need you to rebase off `origin/develop` and squash your commits into one. This will give us a cleaner git history.

Never done this before? No problem. [We'll walk you through it in our guide](/docs/SQUASHING.md), and you can read [a deeper guide about rewriting history to understand more](https://git-scm.com/book/en/v2/Git-Tools-Rewriting-History).

## Running Tests

We use `ExUnit`, Elixir's built-in test framework for unit tests.

Here's [a guide on Elixir School for writing tests](https://elixirschool.com/lessons/basics/testing/).

### Testing helpers

We've written some convenience helper modules and functions to help with API testing. The helpers are found in `test/support` as:

- `CodeCorpsWeb.ApiCase` - used to simplify testing JSON API endpoints
- `CodeCorps.AuthenticationTestHelpers` - provides authentication helpers for authenticating a `conn`
- `CodeCorps.Factories` - provides factories using [`ex_machina`](https://github.com/thoughtbot/ex_machina), which makes it easy to create test data and associations with Ecto
