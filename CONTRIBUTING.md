# Contributing to MarkLogic Workflow

MarkLogic Workflow welcomes new contributors. This document will guide you
through the process.

 - [Question or Problem?](#question)
 - [Issues and Bugs](#issue)
 - [Feature Requests](#feature)
 - [Submission Guidelines](#submit)

## <a name="question"></a> Got a Question or Problem?

If you have questions about how to use MarkLogic Workflow, please direct these to the
Adam Fowler - adam.fowler@marklogic.com.

## <a name="issue"></a> Found an Issue?
If you find a bug in the source code or a mistake in the documentation, you can help us by
submitting an issue to our [GitHub Issue Tracker][issue tracker]. Even better you can submit a Pull Request
with a fix for the issue you filed.

## <a name="feature"></a> Want a Feature?
You can request a new feature by submitting an issue to our [GitHub Issue Tracker][issue tracker].  If you
would like to implement a new feature then first create a new issue and discuss it with one of our
project maintainers.

## <a name="submit"></a> Submission Guidelines

### Submitting an Issue
Before you submit your issue search the archive, maybe your question was already answered.

If your issue appears to be a bug, and hasn't been reported, open a new issue.
Help us to maximize the effort we can spend fixing issues and adding new
features, by not reporting duplicate issues.  Providing the following information will increase the
chances of your issue being dealt with quickly:

* **Overview of the Issue** - if an error is being thrown a stack trace helps
* **Motivation for or Use Case** - explain why this is a bug for you
* **MarkLogic Workflow Version** - is it a named version or from our dev branch
* **Operating System** - Mac, windows? details help
* **Suggest a Fix** - if you can't fix the bug yourself, perhaps you can point to what might be
  causing the problem (line of code or commit)

### Submitting a Pull Request

We use [GitFlow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) to manage the
progress so multiple dev teams can work at the same time. Below is a description.

#### Fork MarkLogic Workflow

First ask Adam Fowler for access to the project, passing him your GitHub account name. Then:-

```sh
$ git clone ssh://user@github.com/adamfowleruk/marklogicworkflow.git
$ cd marklogicworkflow
$ git checkout -b develop origin/develop
```

The following rules apply:-
- master is used only for releases
- A develop branch is used to merge in changes between releases
- Feature branches (feature-ISSUEID) branch off of the develop branch
- Release branches are forked off of develop and called release-sprint-004, testing and builds are done, then merged with master AND then develop
 - Each release is tagged as v1 or v2 etc to match the sprint number until we catch up with the current MarkLogic release number, then we'll adopt v8-2-008 (MarkLogic V8.0-2, sprint 008)
- Hotfix branches are taken off of master, fixed, then committed to master AND then develop

We ask that you open an issue in the [issue tracker][] and get agreement from
at least one of the project maintainers before you start coding.

Nothing is more frustrating than seeing your hard work go to waste because
your vision does not align with that of a project maintainer.


#### Create a branch for your feature

Okay, so you have decided to add something. Create an issue on GitHub if you haven't already, as you'll need the ID.
Now create a feature branch and start hacking:

```sh
$ git checkout -b feature-ISSUEID develop
```

Now develop as normal:-

```sh
$ git status
$ git add myfile
$ git commit
```

To share the branch so others can see it (although advised not to work on it) do this:-

```sh
$ git push --set-upstream origin feature-ISSUEID
```

Now your feature branch [will be visible on GitHub](https://github.com/adamfowleruk/marklogicworkflow/branches).

#### Formatting code

We use [.editorconfig][] to configure our editors for proper code formatting. If you don't
use a tool that supports editorconfig be sure to configure your editor to use the settings
equivalent to our .editorconfig file.

#### Test your code (pre-release mainly)

We are working hard to improve MarkLogic Workflow's testing. If you add new actions
in process models then please write unit tests in the shtests directory.
When finished, verify that the self-test works.

```sh
$ cd shtests
$ ./all.sh
```

Make sure that all tests pass. Please, do not submit patches that fail.


#### Commit your complete feature

When the feature is complete and ready to be integrated back in to the develop branch:-

```sh
$ git commit -m "Fixes #ISSUEID"
$ git pull origin develop
$ git checkout develop
$ git merge feature-ISSUEID
$ git push
$ git branch -d feature-ISSUEID
```

Only do the last command if the others complete successfully. You may have to merge conflicts.

You're now done! Adding the 'Fixes #ISSUEID' comment to the last commit automatically closes the issue with a reference
to your code.

### Further information

- [issue tracker](https://github.com/adamfowleruk/marklogicworkflow/issues)
- [.editorconfig](http://editorconfig.org/)
