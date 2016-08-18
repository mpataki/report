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

  `task help`
    - shows this message
```

## Dependencies

- ruby >= 2.3.0

## TODO:

- [x] `continue`
- [x] `delete`
- [x] `list`
- [x] `current`
- [x] basic `summary`
- [x] gist `summary`
- [x] add configuration file support
- [x] setup install
- [ ] `info` - display information about the current gist file (url, etc)
- [ ] confirmation messages for `delete`
- [ ] add jira support?
  - at the very least, a ticket field
  - stretch goal: add the ability to make new issues, and update time estimates for existing ones
- [ ] allow `summary` to take a gist id, so you can retroactively generate summaries
- [ ] add User.name as well as User.github_username, so we an pretty print

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
