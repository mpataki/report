# Task!

## Installation

TODO

## Usage

```shell
Use `task` as follows:

  `task start TASK-DESCRIPTION`
    - finds or create a new gist for today
    - adds a new item with the provided TASK-DESCRIPTION

  `task list`
    - Lists all of today's tasks

  `task stop`
    - stops time tracking the current task, if it exists

  `task continue [TASK-ID, TASK-DESCRIPTION]`
    - continues tracking the provided task, or latest task if none if provided

  `task delete {TASK-ID, TASK-DESCRIPTION, today, gist}`
    - deletes the provided task if it exists
    - if 'today' is passed, then all tasks in today's report will be deleted
    - if 'gist' is passed, then the whole report gist for today will be deleted

  `task current`
    - lists the currently ongoing task

  `task help`
    - shows this message
```

## System Requirements

- ruby >= 2.3.0

## TODO:

- [x] `continue`
- [ ] `info`
- [x] `delete`
- [ ] confirmation messages for `delete`
- [x] `list`
- [x] `current`
- [ ] `summary`
- [x] rename to `task`
- [ ] setup install

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
