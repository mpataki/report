## Description

This tool enables you to track where your time goes via a private [gist](https://gist.github.com). The data itself is stored in a gist as json, and a formatted summary can be generated and shared (coming soon, actually. Right now there is only a stdout summary). This means that task tracking is not tied to any specific machine, but rather a github account.

## Installation

- [Make a github / gist account.](https://github.com/join?return_to=https%3A%2F%2Fgist.github.com%2F%3Fsignup%3Dtrue&source=header-gist)
- [Generate a Personal Access Token](https://help.github.com/articles/creating-an-access-token-for-command-line-use/) that has read / write access to your gists.
- From a shell:
```shell
gem install task_report
```

- Add your *github user name* and *personal access token* a YAML config file located at `~/.task_report_config`.

Example configuration:
```
user: you_github_username
personal_access_token: 12345678abcdefghi9101112131415jklmnop
```

## Usage

```
Use `task` as follows:

  `task start TASK-DESCRIPTION`
    - finds or creates a new gist for today
    - adds a new item with the provided TASK-DESCRIPTION

  `task stop`
    - stops time tracking the current task, if it exists

  `task continue [TASK-ID, TASK-DESCRIPTION]`
    - continues tracking the provided task, or latest task if none if provided

  `task current`
    - lists the currently ongoing task

  `task list`
    - Lists all of today's tasks

  `task summary [--gist, -g]`
    - prints a task summary to the command line
    - if the `--gist` or `-g` options are used, creates a markdown gist summary
      and prints the link to stdout

  `task delete {TASK-ID, TASK-DESCRIPTION, today, gist}`
    - deletes the provided task if it exists
    - if 'today' is passed, then all tasks in today's report will be deleted
    - if 'gist' is passed, then the whole report gist for today will be deleted

  `task note TASK_ID TASK_NOTE`
    - adds arbitrary note TASK_NOTE to task TASK_ID
    - these notes will be appear in summaries as line items (markdown supported)

  `task help`
    - shows this message
```

## Dependencies

- ruby >= 2.2.3

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
