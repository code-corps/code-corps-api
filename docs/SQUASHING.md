# How do I "squash" my commits?

Before you start, [make sure your text editor is associated with Git](https://help.github.com/articles/associating-text-editors-with-git/) to not close without a response, otherwise you'll see some weird behavior.

Then update your refs to be sure you have the latest code:

```shell
 git fetch --all
```

## Rebase

Rather than merge develop into your branch, we prefer to rebase off of develop. Depending on how you are working with the repo, this step may be different.

If you are working from a forked copy on a branch other than develop (i.e. you created a feature branch) run:

```shell
git rebase -i develop
```

If you are working from a forked copy on the develop branch run:

```shell
git rebase -i HEAD~X
```
With `X` being the number of commits you have added.

If you are working from the main repo run:

```shell
git rebase -i origin/develop
```

This says to rebase your work onto develop.

## Squash

From here, you'll see something like:

```
pick f48d47c The first commit I did
pick fd4e046 The second commit I did
```

You'll want to change everything after your first commit from `pick` to `squash`. This tells git you want to squash these commits into the first one.

From here, you'll get an editor that will let you change the commit messages.

```
# This is a combination of 2 commits.
# The first commit's message is:
The first commit I did

# This is the 2nd commit message:

The second commit I did
```

You'll want to remove or comment out everything except for the first message, which you can edit to be a more complete summary of your changes.

To finish, you'll force push this new commit with the following command:

```shell
git push origin [my-feature-branch] --force-with-lease
```

The `--force-with-lease` flag will refuse to update a branch if someone else has updated it upstream, making your force push a little safer.
